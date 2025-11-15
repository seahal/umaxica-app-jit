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
    get new_help_com_contact_telephone_url(contact_id: @com_contact)

    assert_response :success

    post help_com_contact_telephone_url(contact_id: @com_contact)

    assert_response :created
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
