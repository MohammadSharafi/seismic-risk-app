# Makefile for deploying Flutter web app to GitHub Pages

# Update These Variables
BASE_HREF = '/'
GITHUB_REPO = git@github.com:Marchhealth/march-endo_master_care_sub.git
BUILD_VERSION := $(shell grep 'version:' pubspec.yaml | awk '{print $$2}')
#CUSTOM_DOMAIN = www.marchhealth.co

deploy-web:
	@echo "Cleaning existing repository..."
	flutter clean

	@echo "Getting packages..."
	flutter pub get

	@echo "Building for web..."
	flutter build web --base-href $(BASE_HREF) --release

	#@echo "Creating CNAME file..."
	#echo "$(CUSTOM_DOMAIN)" > build/web/CNAME

	@echo "Committing changes to main repository..."
	git add . && \
	git commit -m "Deploy Version $(BUILD_VERSION)" || echo "Nothing to commit" && \
	git push origin main || { echo "Failed to push to main branch"; exit 1; }

	@echo "Deploying to GitHub Pages (gh-pages branch)..."
	cd build/web && \
	rm -rf .git || echo "No .git directory to remove" && \
	git init && \
	git add . && \
	git commit -m "Deploy Version $(BUILD_VERSION)" && \
	git branch -M gh-pages && \
	git remote add origin $(GITHUB_REPO) && \
	git push -u origin gh-pages || { echo "Failed to push to gh-pages branch"; exit 1; }

	@echo "🟢 Finished Deploy"

.PHONY: deploy-web