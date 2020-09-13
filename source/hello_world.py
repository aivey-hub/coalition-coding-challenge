import json
import datetime


def hello_world_handler(event, context):

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'hello world',
                            'timestamp': datetime.datetime.now().__str__()})
    }
