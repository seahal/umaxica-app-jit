# frozen_string_literal: true

require "test_helper"

class Help::ContactErrorTest < ActiveSupport::TestCase
  setup do
    assert Help.const_defined?(:ContactError)
    assert Help.const_defined?(:ContactNotFoundError)
    assert Help.const_defined?(:ContactIdRequiredError)
    assert Help.const_defined?(:InvalidContactStatusError)
  end

  def test_contact_error_initializes_with_i18n_key
    error = Help::ContactError.new("help.contact.errors.not_found", :not_found)

    assert_equal "help.contact.errors.not_found", error.i18n_key
    assert_equal :not_found, error.status_code
  end

  def test_contact_error_message_from_i18n
    error = Help::ContactError.new("help.contact.errors.not_found", :not_found)

    assert_operator error.message.length, :>, 0
  end

  def test_contact_not_found_error_initializes
    error = Help::ContactNotFoundError.new

    assert_equal "help.contact.errors.not_found", error.i18n_key
    assert_equal :not_found, error.status_code
  end

  def test_contact_id_required_error_initializes
    error = Help::ContactIdRequiredError.new

    assert_equal "help.contact.errors.id_required", error.i18n_key
    assert_equal :bad_request, error.status_code
  end

  def test_invalid_contact_status_error_initializes
    status = "pending"
    error = Help::InvalidContactStatusError.new(status)

    assert_equal "help.contact.errors.invalid_status", error.i18n_key
    assert_equal :unprocessable_entity, error.status_code
    assert_equal({ current_status: status }, error.context)
  end

  def test_invalid_contact_status_error_message_includes_status
    status = "pending"
    error = Help::InvalidContactStatusError.new(status)

    assert_includes error.message, "pending"
  end

  def test_contact_error_inherits_from_application_error
    error = Help::ContactError.new("help.contact.errors.not_found", :not_found)

    assert_kind_of ApplicationError, error
  end

  def test_contact_not_found_error_inherits_from_contact_error
    error = Help::ContactNotFoundError.new

    assert_kind_of Help::ContactError, error
  end

  def test_contact_error_with_custom_context
    error = Help::ContactError.new("help.contact.errors.not_found", :not_found, custom_key: "custom_value")

    assert_equal({ custom_key: "custom_value" }, error.context)
  end
end
