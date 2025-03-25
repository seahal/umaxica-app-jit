[![Hello](https://github.com/seahal/demo-application-ror/actions/workflows/ci.yaml/badge.svg)](https://github.com/seahal/demo-application-ror/actions/workflows/ci.yaml?branch=main) ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit-server/main)
# README


This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
    - Just Do It => `ruby -v`, and check `Gemfile` or `.ruby-version`.
* System dependencies
  - Linux => Run on it.
  - Ruby => Of cource, we are on Ruby.
* Configuration
    - Edit `/etc/hosts` files to separate .com or .net.
    - ```
      # See hosts(5) for details.
	  127.0.0.1   com.www.localdomain app.www.localdomain org.www.localdomain com.api.localdomain app.api.localdomain org.api.localdomain
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
  * Fastly
    * CDN
    * Compute
  * Vercel
    * hosting?
  * CloudFlare
    * Registers
    * Turnstile 
  * Terraform
    * TCP Terraform
* Secrets
  * You have to set `.env.local` and `.envrc` on your own environment.This is because it has confidential.
  * "You can use the AWS CLI command, and then you should run aws configure --profile umaxica."
  * You should use [git-secrets](https://github.com/awslabs/git-secrets).
* Tools
  * `envrc`
  * `yamlfmt`
  * [Lefthook](https://github.com/evilmartians/lefthook)
  * [tflint](https://github.com/terraform-linters/tflint)
  * [asdf](https://asdf-vm.com/)