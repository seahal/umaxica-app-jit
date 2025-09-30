[![CI](https://github.com/seahal/umaxica-app-jit-ruby-on-rails/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit-ruby-on-rails/actions/workflows/integration.yml) ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit-server/main)
# README


This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
    - Find it => `ruby -v`, and check `Gemfile` or `.ruby-version`.
* System dependencies
  - Linux => Run on it.
  - Ruby => Of course, we are on Ruby.
* Configuration
  * ...
* Database creation
    - `bin/rails db:create`
* Database initialization
    - `bin/rails db:migrate` => `bin/rails db:seed`
* How to run the test suite
    - `bin/rails test all`
* Services (job queues, cache servers, search engines, etc.)
    - Redis(ValKey)
    - Kafka
    - PostgreSQL
    - Google Cloud Storage (S3)
    - Terraform
    * Kubernetes
    * [OpenTelemetry](https://opentelemetry.io/)
* Deployment instructions
    - When you are free, look at 'bin/rails notes'
* Using Services
  * Google Cloud
    * CloudRun
    * CloudBuild
    * CloudCDN
    * Social Login
  * CloudFlare
    * Registers
    * Turnstile
    * R2
  * Fastly
    * CDN
  * Resend
    * Email
  * Amazon Web Service
    * SES
  * Terraform
    * TCP Terraform
  * Apple
    * Social Login
* Secrets
  * You have to set `.env.local` and `.envrc` on your own environment. This is because it contains confidential.
  * "You can use the AWS CLI command, and then you should run aws configure --profile umaxica."
  * You should use [git-secrets](https://github.com/awslabs/git-secrets).
  * We began to use Rails' Credentials, but we were unsure how to use them.
* Tools
  * `yamlfmt`
  * [Lefthook](https://github.com/evilmartians/lefthook)
  * [tflint](https://github.com/terraform-linters/tflint)
  * [hadolint](https://github.com/hadolint/hadolint)
  * [Fastly]()
  * bun
  * wrangler
  * [Apple]()
  * [Google]()
