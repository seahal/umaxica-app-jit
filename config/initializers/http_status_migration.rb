# frozen_string_literal: true

# Migrate deprecated Rack/Rails status symbol :unprocessable_entity (422)
# to the recommended :unprocessable_content to silence deprecation warnings
# during tests and runtime.

Rails.application.config.after_initialize do
  begin
    mapping = ActionDispatch::ExceptionWrapper.rescue_responses
    next unless mapping.respond_to?(:transform_values)

    updated = mapping.transform_values { |v|
      sym = v.is_a?(String) ? v.to_sym : v
      sym == :unprocessable_entity ? :unprocessable_content : v
    }

    # Apply the updated mapping via configuration API
    Rails.application.config.action_dispatch.rescue_responses.merge!(updated)
  rescue => e
    Rails.logger.warn "[StatusMigration] Failed to update rescue_responses: #{e.class}: #{e.message}"
  end
end
