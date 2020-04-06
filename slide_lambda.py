from slide import Slide

def handler(event, context):
    try:
        ifttt_event = event['pathParameters']['proxy']
    except:
        ifttt_event = 0
    position = 1 if ifttt_event == 'close' else 0
    sl = Slide()
    sl.move("Livingroom", position)
    sPosition = f'Slide is at position {sl.get_position("Livingroom")}'
    return {
        'statusCode': 200,
        'body':sPosition
    }

if __name__=='__main__':
    handler(None, None)