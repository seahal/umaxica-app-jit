# frozen_string_literal: true

require "test_helper"

class AlreadyAuthenticatedErrorTest < ActiveSupport::TestCase
  def test_defaults
    error = AlreadyAuthenticatedError.new

    assert_equal :forbidden, error.status_code
    assert_equal "errors.messages.already_authenticated", error.i18n_key
  end
end
