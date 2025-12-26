# frozen_string_literal: true

require "test_helper"

class Help::Com::Contact::TelephonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Load fixture directly - it returns ActiveRecord object in Rails 8
    @contact = com_contacts(:one)
    # Create telephone for the contact since resource is singular
    @contact_telephone = ComContactTelephone.create!(
      com_contact: @contact,
      telephone_number: "+81901234567",
      expires_at: 24.hours.from_now,
    )
  end

  # rubocop:disable Minitest/MultipleAssertions
  # test "should redirect edit without valid session" do
  #   get edit_help_com_contact_telephone_url(contact_id: @contact.id)
  #
  #   assert_redirected_to help_com_root_path
  #   assert_equal I18n.t("help.com.contact.telephones.edit.session_expired"), flash[:alert]
  # end
  # rubocop:enable Minitest/MultipleAssertions

  # # rubocop:disable Minitest/MultipleAssertions
  # test "should get edit with valid session" do
  #   @contact_telephone.generate_otp!
  #
  #   contact_id = @contact.id
  #   telephone_id = @contact_telephone.id
  #   expires_at = 10.minutes.from_now.to_i
  #
  #   url = edit_help_com_contact_telephone_url(contact_id: contact_id)
  #
  #   env_hash = {
  #     "rack.session" => {
  #       com_contact_telephone_verification: {
  #         "id" => telephone_id,
  #         "contact_id" => contact_id,
  #         "expires_at" => expires_at
  #       }
  #     }
  #   }
  #
  #   get url, env: env_hash
  #
  #   assert_response :success
  #   # Use contact_id variable instead of @contact.id in string interpolation
  #   assert_select "form[action^='#{help_com_contact_telephone_path(contact_id: contact_id)}']"
  #   assert_select "input[name='com_contact_telephone[otp_code]']"
  # end
  # # rubocop:enable Minitest/MultipleAssertions
end
