# typed: false
# frozen_string_literal: true

require "test_helper"

class IdentifierDetectionTest < ActiveSupport::TestCase
  class TestController
    include IdentifierDetection

    def test_detect_identifier_type(identifier)
      detect_identifier_type(identifier)
    end

    def test_identity_email_model
      identity_email_model
    end

    def test_identity_telephone_model
      identity_telephone_model
    end
  end

  test "detect_identifier_type returns email for @ containing string" do
    controller = TestController.new

    assert_equal :email, controller.test_detect_identifier_type("user@example.com")
  end

  test "detect_identifier_type returns telephone for + containing string" do
    controller = TestController.new

    assert_equal :telephone, controller.test_detect_identifier_type("+819012345678")
  end

  test "detect_identifier_type returns unknown for plain string" do
    controller = TestController.new

    assert_equal :unknown, controller.test_detect_identifier_type("username")
  end

  test "detect_identifier_type returns unknown for blank string" do
    controller = TestController.new

    assert_equal :unknown, controller.test_detect_identifier_type("")
    assert_equal :unknown, controller.test_detect_identifier_type(nil)
  end

  test "identity_email_model returns UserEmail" do
    controller = TestController.new

    assert_equal UserEmail, controller.test_identity_email_model
  end

  test "identity_telephone_model returns UserTelephone" do
    controller = TestController.new

    assert_equal UserTelephone, controller.test_identity_telephone_model
  end
end
