# typed: false
# frozen_string_literal: true

unless Rails.env.production?
  Prosopite.rails_logger = true # Logs to Rails logger.
  Prosopite.prosopite_logger = true # Logs to log/prosopite.log.
  Prosopite.raise = Rails.env.test? # Fail tests on N+1, only log in development.

  # Ignore internal Rails tables during multi-DB boot
  Prosopite.ignore_queries = [
    /SELECT.*FROM.*"ar_internal_metadata"/,
    /SELECT.*FROM.*"schema_migrations"/,
  ]
end
