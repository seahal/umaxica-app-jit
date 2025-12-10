# frozen_string_literal: true

# Helper methods for brand name in tests
module BrandHelper
  # Get the brand name from environment variables
  # @return [String] The brand name
  def brand_name
    (ENV["BRAND_NAME"].presence || ENV["NAME"]).to_s
  end
end

# Include the helper in ActionDispatch::IntegrationTest
ActiveSupport.on_load(:action_dispatch_integration_test) { include BrandHelper }
