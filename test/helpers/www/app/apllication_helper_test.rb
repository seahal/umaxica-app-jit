# frozen_string_literal: true

require "test_helper"

# This test file is obsolete as Www module has been replaced with Sign module
# See test/helpers/sign/app/apllication_helper_test.rb instead
module Www
  module App
    class ApplicationHelperTest < ActionView::TestCase
      test "obsolete - moved to Sign module" do
        skip "This test has been moved to Sign::App::ApplicationHelperTest"
      end
    end
  end
end
