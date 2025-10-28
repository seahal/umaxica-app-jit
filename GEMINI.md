
# Gemini Assistant Configuration

This document provides guidelines for the Gemini AI assistant to ensure its contributions align with the project's standards and conventions.

## Project Overview

This is a Ruby on Rails application named "umaxica-app-jit". It serves as a multi-functional platform featuring a web interface, an API, and various background processing capabilities. The application is built with a modern technology stack, emphasizing security, scalability, and maintainability.

## Key Technologies

- **Backend**: Ruby on Rails 8
- **Frontend**: JavaScript (managed with Bun), TypeScript
- **Database**: PostgreSQL
- **Asynchronous Processing**: Kafka (using the Karafka gem), Redis
- **Search**: Elasticsearch (OpenSearch)
- **Deployment**: Docker, Kubernetes, Terraform
- **CI/CD**: GitHub Actions

## Development Commands

When asked to perform tasks, use the following commands:

- **Run tests**: `bin/rails test`
- **Run RuboCop (Ruby linter)**: `bundle exec rubocop -A`
- **Run Biome (Frontend linter/formatter)**: `bun run format` and `bun run lint`
- **Run Brakeman (Security scanner)**: `bundle exec brakeman`
- **Build frontend assets**: `bun run build`
- **Start development server**: `foreman start -f Procfile.dev`

## Coding Conventions & Architecture

- **Authentication**: Use `webauthn` for passkeys, `rotp` for TOTP, and `omniauth` for social logins (Apple, Google).
- **Authorization**: Use `pundit` for policy-based authorization and `rolify` for role management.
- **API Development**: Use `jbuilder` for creating JSON responses. API documentation is managed with `rswag`.
- **Asynchronous Jobs**: Define consumers in `app/consumers` to process messages from Kafka topics. Use Karafka for this.
- **Service Objects**: Place business logic that doesn't fit in models or controllers into service objects located in `app/services`.
- **File Uploads**: Use Active Storage for direct uploads and CarrierWave for more complex scenarios.
- **Frontend**: Use `jsbundling-rails` to bundle JavaScript. Write modern JavaScript/TypeScript and use `ViewComponent` for reusable UI elements.

## Important Notes

- **Secrets Management**: Do not commit secrets to the repository. Use Rails credentials and environment variables. For local development, developers should manage their own `.env` files.
- **Database Migrations**: The project uses a custom schema organization with multiple `*_schema.rb` files. Be cautious when creating or modifying migrations and refer to the existing structure.
- **Dependency Management**:
  - For Ruby gems, add them to the `Gemfile` and run `bundle install`.
  - For JavaScript packages, add them to `package.json` and run `bun install`.
- **CI/CD Pipeline**: All changes must pass the integration workflow (`.github/workflows/integration.yml`) before being merged. This includes tests, linting, and security checks.
