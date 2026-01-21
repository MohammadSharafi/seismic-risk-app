#!/bin/bash
# Deploy TwinCare Frontend to Cloud Run

set -e

PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-mhp-march-health-platform}"
SERVICE_NAME="twincare-frontend"
REGION="us-central1"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:latest"
BACKEND_URL="${BACKEND_URL:-}"

echo "🚀 Deploying TwinCare Frontend to Cloud Run..."
echo ""

# Check if backend URL is provided
if [ -z "$BACKEND_URL" ]; then
  echo "⚠️  BACKEND_URL not set. Please provide the backend Cloud Run URL."
  echo "   Usage: BACKEND_URL=https://your-backend-url.run.app ./deploy-to-cloud-run.sh"
  echo ""
  read -p "Enter backend URL (or press Enter to skip for now): " BACKEND_URL
fi

# Step 1: Build Docker image
echo "📦 Building Docker image..."
docker build -t ${IMAGE_NAME} .

# Step 2: Push to Google Container Registry
echo "📤 Pushing image to GCR..."
docker push ${IMAGE_NAME}

# Step 3: Deploy to Cloud Run
echo "☁️  Deploying to Cloud Run..."

ENV_VARS=""
if [ -n "$BACKEND_URL" ]; then
  ENV_VARS="--set-env-vars VITE_API_BASE_URL=${BACKEND_URL}"
fi

gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME} \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  ${ENV_VARS} \
  --min-instances 0 \
  --max-instances 10 \
  --memory 512Mi \
  --cpu 1 \
  --port 80

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Frontend URL:"
FRONTEND_URL=$(gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)')
echo "${FRONTEND_URL}"
echo ""
echo "📊 Monitor logs:"
echo "gcloud logging read \"resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME}\" --limit 50"
echo ""
if [ -z "$BACKEND_URL" ]; then
  echo "⚠️  Remember to set VITE_API_BASE_URL environment variable to your backend URL!"
  echo "   Update with: gcloud run services update ${SERVICE_NAME} --region ${REGION} --set-env-vars VITE_API_BASE_URL=https://your-backend-url.run.app"
fi
