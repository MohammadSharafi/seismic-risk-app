import os
import boto3

REGION = "us-east-1"
MODEL_ID = "google.gemma-3-12b-it"

os.environ["AWS_BEARER_TOKEN_BEDROCK"] = "ABSKQmVkcm9ja0FQSUtleS1tM2hjLWF0LTUzMzI2NzM3NzQ3Mjp4bE5HRjlvTGJWSjNSeU1waTNwN1lQVHdvRnZtY1pzVUNReDdIUUwzVDMxcmFDYjd3VForRUhjV3FEdz0="

client = boto3.client("bedrock-runtime", region_name=REGION)

resp = client.converse(
    modelId=MODEL_ID,
    messages=[{
        "role": "user",
        "content": [{"text": "Summarize DKA vs HHS in 6 bullets. End with ### END."}]
    }],
    inferenceConfig={
        "maxTokens": 5000,
        "temperature": 0.0,
        "topP": 1.0
    },
)

print(resp["output"]["message"]["content"][0]["text"])
