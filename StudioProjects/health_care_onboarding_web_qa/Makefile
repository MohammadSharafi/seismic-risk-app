# Makefile for deploying Flutter web app

# Update These Variables
BASE_HREF = '/'
GITHUB_REPO = git@github.com:Marchhealth/march-endo_master_care_sub.git
BUILD_VERSION := $(shell grep 'version:' pubspec.yaml | awk '{print $$2}')

deploy-web:
	@echo "Cleaning existing repository..."
	flutter clean

	@echo "Getting packages..."
	flutter pub get

	@echo "Building for web..."
	flutter build web --base-href $(BASE_HREF) --release

	@echo "Copying build files to repository..."
	rm -rf web
	mv build/web web

	@echo "Staging and committing changes..."
	git add .
	git commit -m "Deploy Version $(BUILD_VERSION)" || echo "No changes to commit"

	@echo "Pushing to repository..."
	git push -u origin main

	@echo "🟢 Finished Deploy"

.PHONY: deploy-web