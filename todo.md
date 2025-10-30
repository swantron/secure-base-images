Go-To-Market Plan: Secure Commercial Base Image

This document outlines the strategy for building, securing, and commercializing a new base image product. The goal is to create a trusted, secure, and marketable asset that other developers and organizations can purchase for their own projects.

1. Repository & Product Definition

Repository: swantron/secure-base-images

Purpose: This monorepo will house the Dockerfile definitions, build/scan pipelines, and documentation for one or more secure base image products.

Initial Product: A minimal, secure base image for running static Go binaries, built using best-in-class security practices.

2. Security-First Development

The core value proposition is security. Our image will not just be scanned; it will be designed to be secure from the ground up.

Multi-Stage Builds: Use the Dockerfile.example as the template. The build environment (builder stage) will contain all the SDKs and tools, but the final production image will not.

Minimal Base Image: Use "distroless" images (e.g., gcr.io/distroless/static-debian11) as the final stage. These images contain only the application and its minimal runtime dependencies.

No Shell, No Package Manager: The final image will not contain bash, sh, apt, apk, or any other shell or package manager, drastically reducing the attack surface.

Non-Root Execution: The image will create and run as a non-privileged nonroot user (uid 65532) by default. This is a critical defense-in-depth practice.

3. Secure CI/CD Pipeline (GitHub Actions)

We will use the publish-to-ecr.yml workflow to automate security and publishing.

Trigger: The pipeline will run on every new GitHub Release (e.g., v1.0.1, v1.1.0). This is a deliberate product decision to version and release images formally, not on every commit.

Security Scanning (Trivy):

The image will be built locally within the runner.

Trivy will scan the image for CRITICAL and HIGH severity OS and library vulnerabilities.

If such vulnerabilities are found, the build will fail.

A SARIF report will be uploaded to the GitHub "Security" tab for review.

Publishing: Only if the Trivy scan passes will the action proceed to push the final, tagged image to the private registry.

4. Commercialization & Distribution Strategy

We will use a "Storefront & Registry" model.

Registry (The "Warehouse"): Amazon ECR (Elastic Container Registry)

This will be our private, backend registry.

The GitHub Actions workflow will push the tagged, secure images here.

Access will be tightly controlled by AWS IAM.

Storefront (The "Cash Register"): AWS Marketplace

This is the customer-facing "buy" page.

We will register as a seller and create a product listing for our image.

Billing: Customers will subscribe to the product, and the charges will appear directly on their monthly AWS bill.

Entitlement: When a customer subscribes, the Marketplace will automatically grant their AWS account the necessary ecr:Pull permissions from our private ECR repository. This automates delivery and access control.

5. Marketing & Visibility

Docker Hub ("The Billboard"):

We will apply for the Docker Verified Publisher program.

We will publish a free, "Community" version of the image (or just a detailed README) to Docker Hub.

This listing will serve as marketing and discovery, with a clear "Purchase Enterprise Version" link directing users to our AWS Marketplace page.

6. Action Plan / Next Steps

[ ] Create the new swantron/secure-base-images repository on GitHub.

[ ] Add the Dockerfile.example (or its equivalent for your specific product) to the repo.

[ ] Create the .github/workflows/ directory and add the publish-to-ecr.yml workflow.

[ ] Go to the AWS Console:

[ ] Create a private ECR Repository (e.g., swantron/secure-base). Note the Registry URL and Repo name.

[ ] Create a dedicated IAM User for GitHub Actions with permissions to log in and push to this ECR repo.

[ ] Begin the registration process for AWS Marketplace Seller.

[ ] Go to the GitHub Repo Settings > Secrets:

[ ] Add AWS_ACCESS_KEY_ID

[ ] Add AWS_SECRET_ACCESS_KEY

[ ] Add AWS_REGION

[ ] Add ECR_REGISTRY (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com)

[ ] Add ECR_REPOSITORY (e.g., swantron/secure-base)

[ ] Commit and push all files.

[ ] Create a v1.0.0 GitHub Release to trigger the first build and publish.

[ ] Complete the AWS Marketplace product listing, pointing it to the ECR image published in the previous step.
