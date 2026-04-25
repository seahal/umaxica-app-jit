# typed: false
# frozen_string_literal: true

require "test_helper"

class TurnstileFormsTest < ActionDispatch::IntegrationTest
  def setup
    # Map of paths that contain Turnstile forms with turbo disabled
    # Format: [Host ENV Name, Path, Description]
    @identity.turnstile_form_paths = [
      { name: "Jit::Identity::Sign::App registration emails", env_key: "IDENTITY_SIGN_APP_URL", path: "/up/emails/new" },
      { name: "Jit::Identity::Sign::App authentication email", env_key: "IDENTITY_SIGN_APP_URL", path: "/in/email/new" },
      # { name: "Jit::Identity::Sign::Org registration emails", env_key: "IDENTITY_SIGN_ORG_URL", path: "/registration/emails/new" },
      # { name: "Jit::Identity::Sign::Org registration passkeys", env_key: "IDENTITY_SIGN_ORG_URL", path: "/registration/passkeys/new" },
      {
        name: "Jit::Foundation::Base::App contacts",
        env_key: "FOUNDATION_BASE_APP_URL",
        path: "/contacts/new",
        headers: base_app_contact_headers,
      },
      { name: "Jit::Foundation::Base::Com contacts", env_key: "FOUNDATION_BASE_COM_URL", path: "/contacts/new" },
    ]
  end

  test "all Turnstile forms have turbo disabled" do
    @identity.turnstile_form_paths.each do |form_config|
      name = form_config[:name]
      env_key = form_config[:env_key]
      path = form_config[:path]

      host = ENV[env_key]
      next if host.blank?

      host! host
      get path, headers: form_config[:headers] || {}

      if response.redirect?
        follow_redirect!
      end

      assert_response :success, "Failed to access #{path} for #{name} (#{host})"

      # Check for Turnstile widget
      has_turnstile = response.body.include?("cf-turnstile") || response.body.include?("cloudflare_turnstile")
      next unless has_turnstile

      # Check for turbo disabled on forms
      assert_select "form[data-turbo='false']", { minimum: 1 },
                    "Expected at least one form with data-turbo='false' in #{name} (#{host})"
    end
  end

  test "Turnstile widget is rendered" do
    @identity.turnstile_form_paths.each do |form_config|
      name = form_config[:name]
      env_key = form_config[:env_key]
      path = form_config[:path]

      host = ENV[env_key]
      next if host.blank?

      host! host
      get path, headers: form_config[:headers] || {}

      if response.redirect?
        follow_redirect!
      end

      assert_response :success, "Failed to access #{path} for #{name} (#{host})"

      # Check for Turnstile widget presence
      assert response.body.include?("cf-turnstile") || response.body.include?("cloudflare_turnstile"),
             "Expected Turnstile widget in #{name} (#{host})"
    end
  end

  test "Turnstile widgets are omitted when disabled" do
    Jit::Security::TurnstileConfig.stub(:enabled?, false) do
      @identity.turnstile_form_paths.each do |form_config|
        name = form_config[:name]
        env_key = form_config[:env_key]
        path = form_config[:path]

        host = ENV[env_key]
        next if host.blank?

        host! host
        get path, headers: form_config[:headers] || {}

        if response.redirect?
          follow_redirect!
        end

        assert_response :success, "Failed to access #{path} for #{name} (#{host})"
        assert_no_match(
          /cf-turnstile|cloudflare_turnstile/,
          response.body,
          "Expected no Turnstile widget in #{name} (#{host})",
        )
      end
    end
  end

  private

  def base_app_contact_headers
    user = users(:one)
    ensure_contact_channels!(user)
    { "X-TEST-CURRENT-USER" => user.id.to_s }
  end

  def ensure_contact_channels!(user)
    user.user_emails.create!(
      address: "turnstile-#{SecureRandom.hex(4)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
    ) unless user.user_emails.exists?

    return if user.user_telephones.exists?

    user.user_telephones.create!(
      number: "+1555#{rand(1_000_000..9_999_999)}",
      user_identity_telephone_status_id: UserTelephoneStatus::VERIFIED,
    )
  end
end
