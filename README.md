# 🚀 Workshop: API de GenAI con Amazon Bedrock y Terraform

¡Bienvenido al taller práctico! En este repositorio aprenderás a
desplegar un **Asistente de QA Automatizado** utilizando una
arquitectura **Serverless (sin servidores)** y **Infraestructura como
Código (IaC)**.

Usaremos **Terraform** para aprovisionar automáticamente **AWS Lambda**
y **API Gateway**, y conectaremos todo con el modelo de Inteligencia
Artificial **Claude 4.5 Haiku** a través de **Amazon Bedrock**.

------------------------------------------------------------------------

## 📋 Prerrequisito Único

-   Una cuenta de AWS activa.\
    (No necesitas instalar nada en tu computadora local; trabajaremos
    **100% en la nube** usando **AWS CloudShell**).

------------------------------------------------------------------------

# 🔴 Paso 0: Preparación del Entorno de Trabajo

En esta sección prepararemos nuestro entorno directamente en AWS en
menos de 5 minutos.

------------------------------------------------------------------------

## 0.1 Habilitar acceso a Claude 4.5 Haiku en Amazon Bedrock

AWS habilita la mayoría de los modelos automáticamente la primera vez
que los invocas. Sin embargo, para modelos de terceros como **Anthropic
(Claude)**, es necesario validar el caso de uso una única vez.

1.  En la barra superior de búsqueda de la consola de AWS, escribe
    **Amazon Bedrock**.
2.  En el menú lateral izquierdo, entra a **Model catalog**.
3.  Busca y selecciona **Claude 4.5 Haiku**.
4.  Haz clic en **Open in Playground**.
5.  Completa el formulario con algo como:

```{=html}
<!-- -->
```
    Educational purposes for a serverless workshop

Listo. El modelo quedará habilitado para tu cuenta.

------------------------------------------------------------------------

### ⚠️ Nota importante sobre facturación

Recibirás un correo automático con el asunto:

**"You accepted an AWS Marketplace offer"**

El costo inicial será **\$0.00**.\
Solo se cobrarán fracciones de centavo por cada petición realizada
durante el taller.

------------------------------------------------------------------------

## 0.2 Uso de AWS CloudShell para evitar instalaciones locales

Para evitar configuraciones locales utilizaremos la terminal integrada
de AWS.

1.  En la consola de AWS, abre **CloudShell**.
2.  Espera a que cargue la terminal.

Ejecuta los siguientes comandos para instalar Terraform:

``` bash
mkdir -p ~/bin
wget https://releases.hashicorp.com/terraform/1.8.0/terraform_1.8.0_linux_amd64.zip
unzip terraform_1.8.0_linux_amd64.zip
mv terraform ~/bin/
rm terraform_1.8.0_linux_amd64.zip
```

Verifica la instalación:

``` bash
terraform version
```

------------------------------------------------------------------------

## 0.3 Descargar el código base

``` bash
git clone https://github.com/AndresDFX/bedrock-qa-workshop.git
cd bedrock-qa-workshop
```

------------------------------------------------------------------------

# 📂 Estructura del Proyecto

-   **main.tf** → Infraestructura Terraform (roles, Lambda, API
    Gateway).
-   **src/lambda_function.py** → Lógica en Python que consume el modelo
    de IA.

------------------------------------------------------------------------

# 🐍 Paso 1: Entendiendo el Código de la IA

El archivo `src/lambda_function.py` realiza tres tareas:

1.  Recibe el reporte de un bug.
2.  Define un **System Prompt** con el rol de QA Engineer.
3.  Invoca **Claude 4.5 Haiku** mediante **boto3**.

💡 **Nota arquitectónica:**\
El prefijo `us.` en el `modelId` utiliza **Inference Profiles** para
alta disponibilidad.

------------------------------------------------------------------------

# 🚀 Paso 2: Desplegar la Infraestructura

Ejecuta los siguientes comandos:

``` bash
terraform init
terraform plan
terraform apply -auto-approve
```

Al finalizar obtendrás un endpoint similar a:

    https://.../analyze-bug

Guarda esa URL.

------------------------------------------------------------------------

# 🎯 Paso 3: Probar tu Asistente de IA

``` bash
curl -s -X POST TU_API_ENDPOINT_AQUI -H "Content-Type: application/json" -d '{"bug_report": "Cuando intento recuperar mi contraseña, la pantalla de carga se queda girando infinitamente y nunca llega el correo de recuperación."}' | jq '.'
```

La IA clasificará automáticamente el bug y devolverá un análisis
estructurado.

------------------------------------------------------------------------

# 🧹 Paso 4: Destruir los Recursos (Evitar Costos)

``` bash
terraform destroy -auto-approve
```

Esto eliminará todos los recursos creados.

------------------------------------------------------------------------

## ✔️ Resultado

Has desplegado una **API Serverless con GenAI** usando:

-   Terraform\
-   AWS Lambda\
-   API Gateway\
-   Amazon Bedrock\
-   Claude 4.5 Haiku

------------------------------------------------------------------------

Desarrollado con ☁️ para la comunidad.
