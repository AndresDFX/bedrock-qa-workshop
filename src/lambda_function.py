import json
import boto3

# Inicializamos el cliente de Bedrock
bedrock = boto3.client(service_name='bedrock-runtime')

def lambda_handler(event, context):
    try:
        # Extraemos el reporte del bug enviado desde el API Gateway
        body = json.loads(event.get('body', '{}'))
        bug_report = body.get('bug_report', 'Error genérico')

        # Instrucción del sistema para la IA
        system_prompt = "Eres un analista de QA experto. Clasifica la severidad del siguiente error (CRÍTICA, ALTA, MEDIA, BAJA) y redacta en 3 viñetas los posibles pasos para reproducirlo."

        # Payload con el formato específico que requiere Claude
        payload = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 500,
            "system": system_prompt,
            "messages": [
                {"role": "user", "content": f"Analiza este reporte: {bug_report}"}
            ]
        }

        # Invocamos al modelo Claude 4.5 Haiku
        response = bedrock.invoke_model(
            modelId='anthropic.claude-haiku-4-5-20251001-v1:0', 
            contentType='application/json',
            accept='application/json',
            body=json.dumps(payload)
        )

        # Procesamos la respuesta
        response_body = json.loads(response.get('body').read())
        ai_response = response_body.get('content')[0].get('text')

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'qa_analysis': ai_response})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }