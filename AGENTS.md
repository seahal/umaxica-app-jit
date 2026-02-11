# AGENTS.md

This file contains guidelines for agentic coding agents working in this Ruby on Rails application.

## Project Overview

This is a multitenant Rails 8.1 application with three main contexts:
- **app/** - Application-level features (end users)
- **com/** - Company-level features (internal teams)  
- **org/** - Organization-level features (organizations)

The application uses Ruby 4.0.1, PostgreSQL, Redis, and follows a service-oriented architecture with strong emphasis on security, auditing, and type safety.

## Essential Commands

### Testing
```bash
# Run all tests
bin/rails test

# Run single test file
bin/rails test test/models/user_test.rb

# Run specific test method
bin/rails test test/models/user_test.rb::test_validation

# Run tests with coverage
COVERAGE=true bin/rails test

# Run performance profiling
TEST_PROF_REPORTS=flamegraph bin/rails test
```

### Linting & Formatting
```bash
# Ruby code style and security
bin/rubocop                    # Lint check
bin/rubocop -a                  # Auto-fix
bin/rubocop --only Style/StringLiterals  # Specific cop

# ERB templates
bundle exec erblint --lint-all   # Check ERB
bundle exec erblint --autocorrect-all  # Fix ERB

# JavaScript/TypeScript (app/javascript)
pnpm run lint                    # Biome lint
pnpm run format                  # Biome format
pnpm run check                   # Biome check & fix

# Security audits
bin/bundler-audit               # Check gem vulnerabilities
bin/brakeman                    # Security scan
```

### Database & Setup
```bash
# Database operations
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset              # Drop, create, migrate, seed

# Development server
bin/dev                         # Start with Foreman
bin/rails server                # Rails server only
bin/rails console               # Rails console
```

### Code Quality
```bash
# Type checking (Sorbet)
bundle exec srb tc               # Type check
bundle exec srb rbi              # Generate RBIs

# Documentation
bundle exec yard                 # Generate docs

# Complexity analysis
bundle exec flog app/            # Method complexity
bundle exec flay app/            # Code duplication
bundle exec reek app/             # Code smells
```

## Code Style Guidelines

### Ruby Standards (from .rubocop.yml)

#### General
- **Ruby Version**: 4.0.1
- **Encoding**: UTF-8 with `# frozen_string_literal: true` at top
- **Line Length**: 120 characters maximum
- **Indentation**: 2 spaces (no tabs)
- **String Literals**: Double quotes preferred
- **Hash Syntax**: Ruby 1.9+ with `{ key: value }` style
- **Arrays**: Use `%w[]` for word arrays, `%i[]` for symbol arrays (3+ items)

#### Method Definitions
```ruby
# Good - parentheses required for method definitions
def my_method(param1, param2)
  # method body
end

# Good - empty method expanded
def empty_method
  # method body
end
```

#### Class Structure (Controllers)
```ruby
class MyController < ApplicationController
  # 1. Module inclusions
  include SomeModule
  prepend AnotherModule

  # 2. Constants
  CONSTANT_VALUE = "value"

  # 3. Macros (before_action, layout, etc.)
  before_action :authenticate_user!
  layout "application"

  # 4. Public class methods
  def self.class_method
    # implementation
  end

  # 5. Initializer
  def initialize
    # implementation
  end

  # 6. Public methods
  def index
    # implementation
  end

  # 7. Protected methods
  protected

  def protected_method
    # implementation
  end

  # 8. Private methods
  private

  def private_method
    # implementation
  end
end
```

#### Error Handling
```ruby
# Good - specific exceptions
begin
  risky_operation
rescue ActiveRecord::RecordNotFound => e
  Rails.logger.error "Record not found: #{e.message}"
  redirect_to root_path, alert: "Record not found"
rescue StandardError => e
  Rails.logger.error "Unexpected error: #{e.message}"
  redirect_to root_path, alert: "Something went wrong"
end

# Avoid broad rescue
begin
  risky_operation
rescue => e  # BAD - too broad
  handle_error
end
```

#### Naming Conventions
- **Classes**: PascalCase (e.g., `UserService`, `AccountRecord`)
- **Methods**: snake_case (e.g., `find_user_by_email`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)
- **Variables**: snake_case (e.g., `user_id`, `is_active`)
- **Files**: snake_case (e.g., `user_service.rb`)

#### Database & Models
- **Primary Keys**: Use `bigserial` by default
- **Timestamps**: Always include `created_at`, `updated_at`
- **Foreign Keys**: Follow `table_name_id` pattern
- **Indexes**: Add appropriate indexes for performance
- **Validations**: Use Rails validators, custom validators for complex logic

#### Service Objects
```ruby
# Base service pattern
class MyService < UniversalService
  def initialize(param1, param2)
    @param1 = param1
    @param2 = param2
  end

  def call
    validate_params
    result = perform_operation
    Success.new(result)
  rescue StandardError => e
    Failure.new(e.message)
  end

  private

  def validate_params
    # validation logic
  end

  def perform_operation
    # main logic
  end
end
```

### JavaScript/TypeScript (app/javascript)
- **Linter**: Biome
- **Formatting**: Biome (2-space indentation)
- **File Extension**: .ts for TypeScript, .js for JavaScript
- **Module System**: ES modules (import/export)

### ERB Templates
- Use `<%== %>` for safe output (Rails 7+)
- Include spaces around ERB tags: `<%= user.name %>`
- Indent ERB consistently with surrounding HTML
- Use partials for repeated markup

## Testing Guidelines

### Test Structure (Minitest)
```ruby
class UserServiceTest < ActiveSupport::TestCase
  test "creates user with valid parameters" do
    user = UserService.new("name", "email@example.com").call
    
    assert user.persisted?
    assert_equal "name", user.name
    assert_equal "email@example.com", user.email
  end

  test "raises error with invalid email" do
    assert_raises(ArgumentError) do
      UserService.new("name", "invalid").call
    end
  end
end
```

### Test Categories
- **Unit Tests**: `test/models/`, `test/services/`, `test/mailers/`
- **Functional Tests**: `test/controllers/`, `test/integration/`
- **System Tests**: `test/system/` (if present)

### Coverage Requirements
- Maintain >90% test coverage
- All critical business logic must be tested
- Use `simplecov` for coverage reports

## Security Guidelines

### Authentication & Authorization
- Use Pundit for authorization policies
- Implement CSRF protection (`protect_from_forgery`)
- Use parameter sanitization (`require`, `permit`)
- Store secrets in Rails credentials

### Data Protection
- Encrypt sensitive data with ActiveRecord encryption
- Use Argon2/BCrypt for password hashing
- Implement rate limiting with Rack::Attack
- Log security events appropriately

### Input Validation
- Always validate user input
- Use Rails strong parameters
- Sanitize HTML output
- Prevent SQL injection (ActiveRecord handles this)

## Performance Guidelines

### Database
- Use database indexes for frequent queries
- Avoid N+1 queries (use `includes`, `joins`, `preload`)
- Use `find_by` instead of `where(...).first`
- Consider read replicas for heavy read operations

### Caching
- Use Solid Cache for application caching
- Implement fragment caching in views
- Cache expensive computations
- Use Redis for session storage

### Background Jobs
- Use Solid Queue for job processing
- Keep jobs small and focused
- Implement job retries with exponential backoff
- Monitor job queue sizes

## Architecture Patterns

### Service Layer
- Business logic in service objects
- Inherit from `UniversalService`
- Use Result pattern (Success/Failure)
- Keep services focused on single responsibilities

### Policy Layer
- Authorization logic in Pundit policies
- One policy per model
- Test all policy methods
- Use query methods for checks (`show?`, `create?`, etc.)

### Concerns
- Share common functionality via concerns
- Keep concerns focused and small
- Use descriptive naming
- Avoid deep inheritance hierarchies

## Development Workflow

1. **Setup**: Run `bin/setup` after cloning
2. **Database**: Ensure migrations are up to date
3. **Testing**: Run tests before committing
4. **Linting**: Fix RuboCop offenses before pushing
5. **Security**: Run `bin/bundler-audit` and `bin/brakeman`
6. **Documentation**: Update Yard documentation for public APIs

## Common Patterns

### Controllers
```ruby
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :update]

  def show
    authorize @user
    render json: @user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
```

### Models
```ruby
class User < ApplicationRecord
  include PublicId
  include Accountably

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :posts, dependent: :destroy

  class << self
    def find_by_email(email)
      find_by("LOWER(email) = ?", email.downcase)
    end
  end
end
```

### Mailers
```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome!")
  end
end
```

## Tools Integration

### IDE Support
- Ruby LSP for language server features
- Sorbet for type checking
- ERB Lint for template validation
- Biome for JavaScript/TypeScript

### CI/CD
- Tests run automatically on PR
- Security scans in pipeline
- Coverage requirements enforced
- Performance tests for critical paths

### Monitoring
- OpenTelemetry for observability
- Structured logging enabled
- Error tracking with Rails error handling
- Performance monitoring with Rack Mini Profiler

Remember to always run the full test suite and linting checks before committing changes. Focus on writing clean, secure, and maintainable code that follows Rails conventions and the specific patterns established in this codebase.