[![CI](https://github.com/seahal/umaxica-app-jit-ruby-on-rails/actions/workflows/integration.yml/badge.svg?branch=main)](https://github.com/seahal/umaxica-app-jit-ruby-on-rails/actions/workflows/integration.yml) ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/seahal/umaxica-app-jit-server/main)
# README


This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
    - Find it => `ruby -v`, and check `Gemfile` or `.ruby-version`.
* System dependencies
  - Ruby => Of course, we are on Ruby.
  - Docker => Run on it.
* Configuration
  * ...
* Database creation
    - `bin/rails db:create`
* Database initialization
  - `bin/rails db:create`
  - `bin/rails db:migrate`
  - `bin/rails db:seed`
* How to run the test suite
  - `bundle exec rails test`
  - `bun test`
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
  * You ought to use [git-secrets](https://github.com/awslabs/git-secrets).
  * We use Rails' Credentials, and if you need them we show you test and dev keys.
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
* Pages
  * com
    * https://umaxica.com
  * app
    * https://umaxica.app
  * org
    * https://umaxica.org
  * info
    * status page => https://umaxica.info
  * net
    * assets cdn => https://umaxica.net
