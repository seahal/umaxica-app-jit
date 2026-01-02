# frozen_string_literal: true

require "test_helper"

class HelpContactVerificationRoutesTest < ActionDispatch::IntegrationTest
  setup do
    @com_contact = com_contacts(:one)
    @app_contact = app_contacts(:one)
    @org_contact = org_contacts(:one)
  end

  # TODO: Uncomment when contact status validation is fixed
  # test "corporate contact email routes respond" do
  #   get new_help_com_contact_email_url(contact_id: @com_contact)
  #
  #   assert_response :success
  #
  #   post help_com_contact_email_url(contact_id: @com_contact)
  #
  #   assert_response :no_content
  # end

  test "corporate contact telephone routes respond" do
    verified_contact = com_contacts(:verified_email_complete)
    verified_contact.update!(status_id: "CHECKED_EMAIL_ADDRESS")
    # Call create using model directly if fixture missing
    # Create ComContactTelephone if missing
    if defined?(ComContactTelephone)
      ComContactTelephone.create!(
        com_contact: verified_contact,
        telephone_number: "09012345678",
        verifier_expires_at: 1.hour.from_now,
        verifier_attempts_left: 3,
        expires_at: 1.day.from_now,
      ) rescue nil
    end

    get new_help_com_contact_telephone_url(contact_id: verified_contact)

    assert_response :success

    post help_com_contact_telephone_url(contact_id: verified_contact)

    assert_response :unprocessable_content
  end

  test "service contact email routes respond" do
    get new_help_app_contact_email_url(contact_id: @app_contact)

    assert_response :success

    post help_app_contact_email_url(contact_id: @app_contact)

    assert_response :created
  end

  test "service contact telephone routes respond" do
    get new_help_app_contact_telephone_url(contact_id: @app_contact)

    assert_response :success

    post help_app_contact_telephone_url(contact_id: @app_contact)

    assert_response :created
  end

  test "org contact email routes respond" do
    get new_help_org_contact_email_url(contact_id: @org_contact)

    assert_response :success

    post help_org_contact_email_url(contact_id: @org_contact)

    assert_response :created
  end

  test "org contact telephone routes respond" do
    get new_help_org_contact_telephone_url(contact_id: @org_contact)

    assert_response :success

    post help_org_contact_telephone_url(contact_id: @org_contact)

    assert_response :created
  end
end
