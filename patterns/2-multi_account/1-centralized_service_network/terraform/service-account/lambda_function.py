import json

def lambda_handler(event, context):    
    # Create response
    response_body = {
        'message': 'Hello from Lambda Function!!',
    }
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps(response_body)
    }