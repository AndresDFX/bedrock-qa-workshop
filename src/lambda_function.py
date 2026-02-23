import json
import boto3

# Inicializamos el cliente de Bedrock
bedrock = boto3.client(service_name='bedrock-runtime')

def lambda_handler(event, context):
    try:
        # Extraemos el reporte del bug
        body = json.loads(event.get('body', '{}'))
        bug_report = body.get('bug_report', 'Error genérico')

        system_prompt = "Eres un analista de QA experto. Clasifica la severidad del siguiente error (CRÍTICA, ALTA, MEDIA, BAJA) y redacta en 3 viñetas los posibles pasos para reproducirlo."

        payload = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 500,
            "system": system_prompt,
            "messages": [
                {"role": "user", "content": f"Analiza este reporte: {bug_report}"}
            ]
        }

        # Invocamos al modelo usando el Cross-Region Inference Profile
        response = bedrock.invoke_model(
            modelId='us.anthropic.claude-haiku-4-5-20251001-v1:0', 
            contentType='application/json',
            accept='application/json',
            body=json.dumps(payload)
        )

        response_body = json.loads(response.get('body').read())
        ai_response = response_body.get('content')[0].get('text')

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json; charset=utf-8'
            },
            # ensure_ascii=False evita que se rompan las tildes y las eñes en la respuesta
            'body': json.dumps({'qa_analysis': ai_response}, ensure_ascii=False)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }