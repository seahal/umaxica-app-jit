require "test_helper"

class NotAuthenticatedErrorTest < ActiveSupport::TestCase
  def test_defaults
    error = NotAuthenticatedError.new

    assert_equal :unauthorized, error.status_code
    assert_equal "errors.messages.login_required", error.i18n_key
  end
end
