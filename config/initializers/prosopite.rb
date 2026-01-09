# frozen_string_literal: true

unless Rails.env.production?
  Prosopite.rails_logger = true       # Logs to Rails logger.
  Prosopite.prosopite_logger = true   # Logs to log/prosopite.log.
  Prosopite.raise = true              # Raise on N+1 to fail tests.
  Prosopite.scan
end
