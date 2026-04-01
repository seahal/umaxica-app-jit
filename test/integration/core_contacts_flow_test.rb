# typed: false
# frozen_string_literal: true

require "test_helper"

class CoreContactsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @app_host = ENV.fetch("CORE_SERVICE_URL", "ww.app.localhost")
    @org_host = ENV.fetch("CORE_STAFF_URL", "ww.org.localhost")
    @com_host = ENV.fetch("CORE_CORPORATE_URL", "ww.com.localhost")

    @user = users(:one)
    @staff = staffs(:one)

    ensure_contact_references!
  end

  teardown do
    CloudflareTurnstile.test_mode = false
    CloudflareTurnstile.test_validation_response = nil
  end

  test "app contacts new redirects when not logged in" do
    host! @app_host
    get new_core_app_contact_url

    assert_response :redirect
  end

  test "app contacts requires registered email and telephone in new/create" do
    host! @app_host
    clear_user_channels(@user)

    get new_core_app_contact_url, headers: app_auth_headers(@user)

    assert_response :unprocessable_content
    assert_equal "email を登録してください", response.body

    add_user_email(@user)

    get new_core_app_contact_url, headers: app_auth_headers(@user)

    assert_response :unprocessable_content
    assert_equal "telephone を追加してください", response.body

    post core_app_contacts_url, headers: app_auth_headers(@user), params: {
      app_contact: base_contact_params.merge(title: "A", body: "B"),
    }

    assert_response :unprocessable_content
    assert_equal "telephone を追加してください", response.body
  end

  test "app contacts creates inquiry directly and validates title/body boundaries" do
    host! @app_host
    clear_user_channels(@user)
    add_user_email(@user)
    add_user_telephone(@user)

    Jit::Security::TurnstileConfig.stub(:stealth_secret_key, nil) do
      get new_core_app_contact_url, headers: app_auth_headers(@user)

      assert_response :success

      assert_difference(
        ["AppContact.count", "AppContactTopic.count", "AppContactEmail.count",
         "AppContactTelephone.count",], 1,
      ) do
        post core_app_contacts_url, headers: app_auth_headers(@user), params: {
          app_contact: base_contact_params.merge(title: "a" * 80, body: "b" * 8000),
        }
      end
      assert_response :redirect
      contact = AppContact.order(:id).last

      assert_equal AppContactStatus::SET_UP, contact.status_id
      assert_equal "a" * 80, contact.app_contact_topics.last.title

      assert_no_difference("AppContact.count") do
        post core_app_contacts_url, headers: app_auth_headers(@user), params: {
          app_contact: base_contact_params.merge(title: "a" * 81, body: "body"),
        }
      end
      assert_response :unprocessable_content

      assert_no_difference("AppContact.count") do
        post core_app_contacts_url, headers: app_auth_headers(@user), params: {
          app_contact: base_contact_params.merge(title: "valid title", body: "b" * 8001),
        }
      end
      assert_response :unprocessable_content
    end
  end

  test "org contacts new redirects when not logged in" do
    host! @org_host
    get new_core_org_contact_url

    assert_response :redirect
  end

  test "org contacts requires registered email and telephone" do
    host! @org_host
    clear_staff_channels(@staff)

    get new_core_org_contact_url, headers: org_auth_headers(@staff)

    assert_response :unprocessable_content
    assert_equal "email を登録してください", response.body

    add_staff_email(@staff)
    get new_core_org_contact_url, headers: org_auth_headers(@staff)

    assert_response :unprocessable_content
    assert_equal "telephone を追加してください", response.body
  end

  test "org contacts creates inquiry directly" do
    host! @org_host
    clear_staff_channels(@staff)
    add_staff_email(@staff)
    add_staff_telephone(@staff)

    Jit::Security::TurnstileConfig.stub(:stealth_secret_key, nil) do
      assert_difference(
        ["OrgContact.count", "OrgContactTopic.count", "OrgContactEmail.count",
         "OrgContactTelephone.count",], 1,
      ) do
        post core_org_contacts_url, headers: org_auth_headers(@staff), params: {
          org_contact: base_contact_params.merge(
            category_id: OrgContactCategory::ORGANIZATION_INQUIRY,
            title: "Org inquiry",
            body: "Org body",
          ),
        }
      end
      assert_response :redirect
      contact = OrgContact.order(:id).last

      assert_equal OrgContactStatus::SET_UP, contact.status_id
    end
  end

  test "org contacts new with invalid category renders form with nil category" do
    host! @org_host
    clear_staff_channels(@staff)
    add_staff_email(@staff)
    add_staff_telephone(@staff)

    get new_core_org_contact_url(category: "invalid"), headers: org_auth_headers(@staff)

    assert_response :success
  end

  test "org contacts new with valid category passes category to form" do
    host! @org_host
    clear_staff_channels(@staff)
    add_staff_email(@staff)
    add_staff_telephone(@staff)

    category = OrgContactCategory.first
    get new_core_org_contact_url(category: category.id), headers: org_auth_headers(@staff)

    assert_response :success
  end

  test "org contacts with turnstile stealth validation" do
    host! @org_host
    clear_staff_channels(@staff)
    add_staff_email(@staff)
    add_staff_telephone(@staff)

    Jit::Security::TurnstileConfig.stub(:stealth_secret_key, "test_secret") do
      Jit::Security::TurnstileVerifier.stub(:verify, { "success" => true }) do
        assert_difference(
          ["OrgContact.count", "OrgContactTopic.count", "OrgContactEmail.count",
           "OrgContactTelephone.count",], 1,
        ) do
          post core_org_contacts_url, headers: org_auth_headers(@staff), params: {
            :org_contact => base_contact_params.merge(
              category_id: OrgContactCategory::ORGANIZATION_INQUIRY,
              title: "Org inquiry with turnstile",
              body: "Org body with turnstile",
            ),
            "cf-turnstile-response" => "test_token",
          }
        end
        assert_response :redirect
      end
    end
  end

  test "org contacts fails with invalid topic" do
    host! @org_host
    clear_staff_channels(@staff)
    add_staff_email(@staff)
    add_staff_telephone(@staff)

    Jit::Security::TurnstileConfig.stub(:stealth_secret_key, nil) do
      post core_org_contacts_url, headers: org_auth_headers(@staff), params: {
        org_contact: base_contact_params.merge(
          category_id: OrgContactCategory::ORGANIZATION_INQUIRY,
          title: "",
          body: "",
        ),
      }

      assert_response :unprocessable_content
    end
  end

  test "com contacts completes contact on submit without verification" do
    host! @com_host
    CloudflareTurnstile.test_mode = true
    CloudflareTurnstile.test_validation_response = { "success" => true }

    get new_core_com_contact_url

    assert_response :success

    assert_difference(["ComContact.count", "ComContactTopic.count"], 1) do
      post core_com_contacts_url, params: {
        com_contact: {
          category_id: ComContactCategory::SECURITY_ISSUE,
          confirm_policy: "1",
          email_address: "public-#{SecureRandom.hex(4)}@example.com",
          telephone_number: "+1555#{rand(1_000_000..9_999_999)}",
          title: "Public inquiry",
          body: "Public body",
        },
      }
    end

    contact = ComContact.order(created_at: :desc).first

    assert_equal ComContactStatus::COMPLETED_CONTACT_ACTION, contact.status_id

    assert_response :redirect
    assert_includes @response.redirect_url, "/contacts/#{contact.public_id}"
    assert_not_includes @response.redirect_url, "/email"
  end

  private

  def ensure_contact_references!
    AppContactCategory.find_or_create_by!(id: AppContactCategory::APPLICATION_INQUIRY)
    OrgContactCategory.find_or_create_by!(id: OrgContactCategory::ORGANIZATION_INQUIRY)
    ComContactCategory.find_or_create_by!(id: ComContactCategory::SECURITY_ISSUE)
    AppContactStatus.find_or_create_by!(id: AppContactStatus::SET_UP)
    OrgContactStatus.find_or_create_by!(id: OrgContactStatus::SET_UP)
    ComContactStatus.find_or_create_by!(id: ComContactStatus::SET_UP)
    ComContactStatus.find_or_create_by!(id: ComContactStatus::COMPLETED_CONTACT_ACTION)
  end

  def base_contact_params
    {
      category_id: AppContactCategory::APPLICATION_INQUIRY,
      confirm_policy: "1",
    }
  end

  def clear_user_channels(user)
    user.user_emails.delete_all
    user.user_telephones.delete_all
  end

  def add_user_email(user)
    user.user_emails.create!(
      address: "user-#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    )
  end

  def add_user_telephone(user)
    user.user_telephones.create!(
      number: "+1555#{rand(1_000_000..9_999_999)}",
      user_identity_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
  end

  def clear_staff_channels(staff)
    staff.staff_emails.delete_all
    staff.staff_telephones.delete_all
  end

  def add_staff_email(staff)
    staff.staff_emails.create!(
      address: "staff-#{SecureRandom.hex(4)}@example.com",
      staff_identity_email_status_id: StaffEmailStatus::VERIFIED,
    )
  end

  def add_staff_telephone(staff)
    staff.staff_telephones.create!(
      number: "+1555#{rand(1_000_000..9_999_999)}",
      staff_identity_telephone_status_id: StaffTelephoneStatus::VERIFIED,
    )
  end

  def app_auth_headers(user)
    { "X-TEST-CURRENT-USER" => user.id.to_s }
  end

  def org_auth_headers(staff)
    { "X-TEST-CURRENT-STAFF" => staff.id.to_s }
  end
end
