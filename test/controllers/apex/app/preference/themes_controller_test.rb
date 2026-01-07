# frozen_string_literal: true

require "test_helper"

require_relative "../../../../support/cookie_helper"

module Apex
  module App
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        setup do
          host! ENV.fetch("APEX_SERVICE_URL", "app.localhost")
          https!
        end
      end
    end
  end
end
