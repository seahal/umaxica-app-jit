[![CI](https://github.com/seahal/umaxica-app-jit-ruby-on-rails/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit-ruby-on-rails/actions/workflows/integration.yml) [![CD](https://github.com/seahal/umaxica-app-jit-ruby-on-rails/actions/workflows/delivery.yaml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit-ruby-on-rails/actions/workflows/delivery.yaml)  ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit-server/main)
# README


This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
    - Just Do It => `ruby -v`, and check `Gemfile` or `.ruby-version`.
* System dependencies
  - Linux => Run on it.
  - Ruby => Of course, we are on Ruby.
* Configuration
    - Edit `/etc/hosts` files to separate .com or .net.
    - ```
      # 
	     127.0.0.1   com.api.localdomain net.api.localdomainc org.api.localdomain app.api.localdomain com.www.localdomain net.www.localdomain org.www.localdomain app.www.localdomain localhost
	  ```
* Database creation
    - `bin/rails db:create`
* Database initialization
    - `bin/rails db:migrate` => `bin/rails db:seed`
* How to run the test suite
    - `bin/rails test all`
* Services (job queues, cache servers, search engines, etc.)
    - Elasticsearch
    - Redis
    - Kafka
    - S3(minio)
    - Terraform
    * Kubernetes
    * [OpenTelemetry](https://opentelemetry.io/)
* Deployment instructions
    - When you are free, look at 'bin/rails notes'
* Using Services
  * Amazon Web Service
    * ses
    * AWS End User Messaging
    * ecr
    * eks
    * cloudfront
      * functions
  * CloudFlare
    * Registers
    * Turnstile
    * Workers
  * Fastly
    * CDN
    * Compute
  * Terraform
    * TCP Terraform
* Secrets
  * You have to set `.env.local` and `.envrc` on your own environment.This is because it has confidential.
  * "You can use the AWS CLI command, and then you should run aws configure --profile umaxica."
  * You should use [git-secrets](https://github.com/awslabs/git-secrets).
  * We began to use Rails' Credentials, but we were unsure how to use them.
* Tools
  * `envrc`
  * `yamlfmt`
  * [Lefthook](https://github.com/evilmartians/lefthook)
  * [tflint](https://github.com/terraform-linters/tflint)
  * [asdf](https://asdf-vm.com/)
  * [hadolint](https://github.com/hadolint/hadolint)
  * fastly
  * bun
  * wrangler