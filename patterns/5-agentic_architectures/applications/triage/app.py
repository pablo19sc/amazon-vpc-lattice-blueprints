# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
"""Helpdesk 'triage' specialist agent, served over the A2A protocol (Strands Agents A2AServer).

It runs on Amazon ECS behind a VPC Lattice service, or on Amazon Bedrock AgentCore Runtime with the A2A server
protocol. Both expect an A2A server on port 9000 at the root path. PUBLIC_URL is the URL advertised in the agent
card (/.well-known/agent-card.json): the VPC Lattice service URL when it runs behind VPC Lattice.

The model depends on CONNECTIVITY_MODE:

- self_hosted_gateway: the AI gateway's model endpoint, found in AWS Agent Registry at start-up and called through
  VPC Lattice (SigV4) with the triage agent's virtual key.
- any other mode: Amazon Bedrock (MODEL_ID).
"""
import json
import logging
import os
import socket
import time

import boto3
import httpx
from botocore.auth import SigV4Auth
from botocore.awsrequest import AWSRequest
from botocore.config import Config
from strands import Agent
from strands.models import BedrockModel
from strands.models.openai import OpenAIModel
from strands.multiagent.a2a import A2AServer

logging.basicConfig(level=logging.INFO)
log = logging.getLogger("triage")

REGION = os.environ.get("AWS_REGION", "eu-west-1")
MODE = os.environ.get("CONNECTIVITY_MODE", "direct")
MODEL_ID = os.environ.get("MODEL_ID", "eu.anthropic.claude-haiku-5-5")
session = boto3.session.Session(region_name=REGION)


class LatticeAuth(httpx.Auth):
    """Sign httpx requests with SigV4 for VPC Lattice (vpc-lattice-svcs, unsigned payload)."""

    requires_request_body = True

    def auth_flow(self, request):
        headers = {"host": request.url.netloc.decode(), "x-amz-content-sha256": "UNSIGNED-PAYLOAD"}
        if "content-type" in request.headers:
            headers["content-type"] = request.headers["content-type"]
        aws_request = AWSRequest(method=request.method, url=str(request.url), data=request.content, headers=headers)
        aws_request.context["payload_signing_enabled"] = False
        SigV4Auth(session.get_credentials().get_frozen_credentials(), "vpc-lattice-svcs", REGION).add_auth(aws_request)
        for name, value in aws_request.headers.items():
            request.headers[name] = value
        yield request


def gateway_llm():
    """The gateway's model endpoint from AWS Agent Registry. Waits for the record: deploy.sh submits it for approval
    after the triage service starts."""
    client = session.client("agent-registry", endpoint_url=os.environ.get("REGISTRY_ENDPOINT_URL") or None)
    registry_id = os.environ["REGISTRY_ID"]
    while True:
        record_ids = [r["recordId"] for r in client.list_discoverable_registry_records(registryId=registry_id)["registryRecords"]]
        if record_ids:
            records = client.batch_get_discoverable_registry_record(
                entries=[{"registryId": registry_id, "recordIds": record_ids}])["registryRecords"]
            for record in records:
                custom = record.get("descriptors", {}).get("custom")
                if custom and json.loads(custom["data"]).get("protocol") == "openai":
                    llm = json.loads(custom["data"])
                    log.info(json.dumps({"model_endpoint": record["name"], "url": llm["baseUrl"]}))
                    return llm
        log.info("Waiting for the gateway's model endpoint in AWS Agent Registry")
        time.sleep(15)


def build_model():
    if MODE != "self_hosted_gateway":
        # One long-lived model client: TCP keepalives (interval set by the task's net.ipv4.tcp_keepalive_time) stop
        # its idle connection to the centralized bedrock-runtime endpoint from timing out in VPC Lattice
        return BedrockModel(model_id=MODEL_ID, boto_session=session, boto_client_config=Config(tcp_keepalive=True))
    llm = gateway_llm()
    secret = session.client("secretsmanager").get_secret_value(SecretId=os.environ["LITELLM_API_KEY_SECRET_ARN"])["SecretString"]
    key = secret if secret.startswith("sk-") else f"sk-{secret}"
    # Same keepalive for the pooled connection to the gateway
    transport = httpx.AsyncHTTPTransport(socket_options=[(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)])
    http_client = httpx.AsyncClient(auth=LatticeAuth(), headers={"x-litellm-api-key": f"Bearer {key}"}, timeout=120,
                                    transport=transport)
    return OpenAIModel(client_args={"base_url": llm["baseUrl"], "api_key": "via-x-litellm-api-key", "http_client": http_client},
                       model_id=llm["models"][0])


agent = Agent(
    name="triage",
    description="Helpdesk triage agent: decides the priority (low, medium, high) of an IT issue.",
    model=build_model(),
    system_prompt=(
        "You triage IT helpdesk issues. Reply with one word, the priority (low, medium or high), followed by a "
        "one-sentence reason. Hardware that stops an employee from working is high."
    ),
    callback_handler=None,
)

if __name__ == "__main__":
    A2AServer(agent=agent, host="0.0.0.0", port=9000, http_url=os.environ.get("PUBLIC_URL"), serve_at_root=True).serve()
