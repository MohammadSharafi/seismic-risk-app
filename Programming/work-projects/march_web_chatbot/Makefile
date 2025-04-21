# Makefile for deploying Flutter web app to GitHub Pages

# Update These Variables
BASE_HREF = '/website-toggle-chat/'
GITHUB_REPO = git@github.com:Marchhealth/website-toggle-chat.git
BUILD_VERSION := $(shell grep 'version:' pubspec.yaml | awk '{print $$2}')


deploy-web:
	@echo "Clean existing repository..."
	flutter clean

	@echo "Getting packages..."
	flutter pub get

	@echo "Building for web..."
	flutter build web --base-href $(BASE_HREF) --release

	@echo "Creating version file..."
	@echo "$(BUILD_VERSION)" > build/web/version.txt

	@echo "Updating index.html with version..."
	sed -i'' -e 's|main.dart.js|main.dart.js?version=$(BUILD_VERSION)|' build/web/index.html

	@echo "PUSH & COMMIT"
	git add . && \
	git commit -m "Deploy Version $(BUILD_VERSION)" || echo "Nothing to commit" && \
	git push -u origin main

	@echo "Deploying to git repository"
	cd build/web && \
	git init && \
	git add . && \
	git commit -m "Deploy Version $(BUILD_VERSION)" && \
	git branch -M main && \
	git remote add origin $(GITHUB_REPO) && \
	git push -u --force origin main

	@echo "🟢 Finished Deploy"

.PHONY: deploy-web


