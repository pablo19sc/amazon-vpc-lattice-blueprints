import json

def lambda_handler(event, context):
    # Extract headers from the event
    headers = event.get('headers', {}) if event.get('headers') else {}
    
    # Create response with headers and message
    response_body = {
        'message': 'Hello from Lambda!',
        'received_headers': headers
    }
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps(response_body)
    }