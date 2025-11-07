# frozen_string_literal: true

require "test_helper"

module Top
  module Com
    module Preference
      class ThemesControllerTest < ActionDispatch::IntegrationTest
        # NOTE: Theme functionality for top/com has been moved to Hono application
        # Controller exists but raises NotImplementedError when theme_redirect_url is called

        test "placeholder test for themes controller" do
          skip "Theme functionality has been moved to Hono application"
        end
      end
    end
  end
end
