## How to Control your slide with Alexa, part 2, connect to IFTTT
#### 1. Create an AWS API Gateway API
https://console.aws.amazon.com/apigateway/main/apis?region=us-east-1
`REST API` → `build`    
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`REST` → `New API`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Protocol: `REST`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;API Name: `IFTTT_to_Slide`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Endpoint Type: `Regional`

On the root of the API, create a new Child Resource.  
`Actions` → `Create Resource`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Configure as proxy resource: `Yes`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Resource Name: `proxy`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Resource Path: `{proxy+}`

On the `/{proxy+} - ANY - Setup page` use the following settings:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Integration type: `Lambda Function Proxy`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lambda Region: Whatever region you are using, like `us-east-1`
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lambda Function: `slide_lambda`

Once the method has been created, we can deploy the API.  
Click the `Actions` drop down → `Deploy API`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Deployment stage: `[New Stage]`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Stage name: `ifttt`

The invoke URL is shown on the screen now. It looks something like:
  https://r3gv3rmtbg.execute-api.us-east-1.amazonaws.com/ifttt

#### 2. Connect Alexa to IFTTT
  https://ifttt.com/amazon_alexa

Create a new applet  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;https://ifttt.com/discover?source=get_more_header_button  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Click `[ + ]`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Click `IF [+]` → `Amazon Alexa` → `Say a specific phrase`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Fill in phrase like: `Alexa, open the curtains`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Click `THEN [+]` → `Web hooks`  

Fill in your invoke URL followed by the event `/open` or `/close`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Method: `POST`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Content Type: `application/json`  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Body: (leave empty)  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`Create action`  

Done!

---
credits: https://medium.com/@daniel.woods/use-alexa-ifttt-to-control-your-aws-environment-ffe48ceb5da4

