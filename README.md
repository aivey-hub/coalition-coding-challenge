# coalition-coding-challenge

Infrastructure and application code for AWS API endpoint that returns "hello world" to the following curl command:
```bash
curl http://<api_endpoint>/
```
with the expected output of
```json 
{

	“message” : “hello world”,

	“timestamp”: <current time>

}
```
## Installation
Ensure aws credentials are configured. Clone repo. In the root of the repo run: 
```bash
terraform init
terraform apply
```

## Usage
On terraform apply the output will display the url of the api endpoint
```bash
Outputs:

endpoint_url = https://rtcogxe069.execute-api.us-east-1.amazonaws.com/helloWorld
```
You can then curl that endpoint to obtain the response
```bash
aivey-mac:coalition-coding-challenge aivey$ curl https://rtcogxe069.execute-api.us-east-1.amazonaws.com/helloWorld
{"message": "hello world", "timestamp": "2020-09-14 17:29:19.791079"}
```
