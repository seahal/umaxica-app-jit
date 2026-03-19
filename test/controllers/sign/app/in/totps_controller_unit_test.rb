# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::App::In::TotpsControllerUnitTest < ActiveSupport::TestCase
  FakeRequest = Struct.new(:remote_ip, keyword_init: true)

  class FakeSecretRelation
    def initialize(secrets)
      @secrets = secrets
    end

    def where(*)
      self
    end

    def order(*)
      self
    end

    def limit(*)
      @secrets
    end
  end

  class FakeTotpRelation
    def initialize(records)
      @records = records
    end

    def order(*)
      @records
    end
  end

  setup do
    @controller = Sign::App::In::TotpsController.new
    @session = {}.freeze
    @params = {}.with_indifferent_access
    @request = FakeRequest.new(remote_ip: "127.0.0.1")

    @controller.define_singleton_method(:session) { @session_ref }
    @controller.instance_variable_set(:@session_ref, @session)
    @controller.define_singleton_method(:params) { @params_ref }
    @controller.instance_variable_set(:@params_ref, @params)
    @controller.define_singleton_method(:request) { @request_ref }
    @controller.instance_variable_set(:@request_ref, @request)
    @controller.define_singleton_method(:render) { |*args, **kwargs| @_test_rendered = { args:, **kwargs }.freeze }
    @controller.define_singleton_method(:redirect_to) { |path, **kwargs| @_test_redirected = [path, kwargs].freeze }
    @controller.define_singleton_method(:t) { |key| "translated:#{key}" }
  end

  test "ensure_mfa_user redirects when session user is absent" do
    @controller.define_singleton_method(:new_sign_app_in_path) { "/sign/app/in/new" }

    @controller.send(:ensure_mfa_user!)

    assert_equal ["/sign/app/in/new", { status: :see_other }], @controller.instance_variable_get(:@_test_redirected)
  end

  test "clear_mfa_session removes the session key" do
    @session[Sign::App::In::TotpsController::MFA_USER_SESSION_KEY] = 42

    @controller.send(:clear_mfa_session!)

    assert_not @session.key?(Sign::App::In::TotpsController::MFA_USER_SESSION_KEY)
  end

  test "verify_totp_for returns first matching totp and nil when nothing matches" do
    first = Struct.new(:private_key).new("key-1")
    second = Struct.new(:private_key).new("key-2")
    user = Struct.new(:active_totps).new(FakeTotpRelation.new([first, second]))

    totp_double =
      Struct.new(:result) do
        define_method(:verify) do |_token|
          result
        end
      end

    ROTP::TOTP.stub :new, ->(private_key) { totp_double.new((private_key == "key-2") ? 123_456 : nil) } do
      last_otp_at, record = @controller.send(:verify_totp_for, user, "123456")

      assert_equal 123_456, last_otp_at
      assert_equal second, record
    end

    ROTP::TOTP.stub :new, ->(_private_key) { totp_double.new(nil) } do
      last_otp_at, record = @controller.send(:verify_totp_for, user, "000000")

      assert_nil last_otp_at
      assert_nil record
    end
  end

  test "active_secret_hints_for truncates active secret names" do
    secrets = [
      Struct.new(:name).new("ABCD-secret"),
      Struct.new(:name).new("EFGH-secret"),
    ]
    user = Struct.new(:user_secrets).new(FakeSecretRelation.new(secrets))

    assert_equal %w(ABCD EFGH), @controller.send(:active_secret_hints_for, user)
  end

  test "handle_totp_success renders hard reject when session limit blocks login" do
    user = Struct.new(:id).new(1)
    totp_record = Struct.new(:updated_at) do
      define_method(:update!) { |**_kwargs| nil }
    end.new
    rendered_limit = nil

    Rails.event.stub :notify, nil do
      @controller.define_singleton_method(:log_in) { |_user, **_kwargs|
        { status: :session_limit_hard_reject, message: "too many", http_status: :forbidden }
      }
      @controller.define_singleton_method(:render_session_limit_hard_reject) do |message:, http_status:|
        rendered_limit = { message:, http_status: }
      end

      @controller.handle_totp_success(user, totp_record, 123_456)
    end

    assert_equal({ message: "too many", http_status: :forbidden }, rendered_limit)
  end

  test "handle_totp_success redirects to session page when restricted" do
    user = Struct.new(:id).new(1)
    totp_record = Struct.new(:updated_at) do
      define_method(:update!) { |**_kwargs| nil }
    end.new

    Rails.event.stub :notify, nil do
      @controller.define_singleton_method(:log_in) { |_user, **_kwargs| { restricted: true } }
      @controller.define_singleton_method(:sign_app_in_session_path) { "/sign/app/in/session" }

      @controller.handle_totp_success(user, totp_record, 123_456)
    end

    assert_equal ["/sign/app/in/session", { notice: I18n.t("sign.app.in.session.restricted_notice") }],
                 @controller.instance_variable_get(:@_test_redirected)
  end

  test "handle_totp_success issues checkpoint and redirects on success" do
    user = Struct.new(:id).new(1)
    updated_values = nil
    totp_record = Struct.new(:updated_at) do
      define_method(:update!) { |**kwargs| updated_values = kwargs }
    end.new
    checkpoint_issued = false
    @params[:ri] = "jp"

    Rails.event.stub :notify, nil do
      @controller.define_singleton_method(:log_in) { |_user, **_kwargs| { status: :success, restricted: false } }
      @controller.define_singleton_method(:issue_checkpoint!) { checkpoint_issued = true }
      @controller.define_singleton_method(:sign_app_in_checkpoint_path) { |ri:| "/sign/app/in/checkpoint?ri=#{ri}" }

      @controller.handle_totp_success(user, totp_record, 123_456)
    end

    assert checkpoint_issued
    assert_equal({ last_otp_at: Time.zone.at(123_456) }, updated_values)
    assert_equal ["/sign/app/in/checkpoint?ri=jp", { notice: "translated:sign.app.authentication.totp.success" }],
                 @controller.instance_variable_get(:@_test_redirected)
    assert_not @session.key?(Sign::App::In::TotpsController::MFA_USER_SESSION_KEY)
  end

  test "handle_totp_failure adds an error and renders new" do
    form = Sign::App::In::TotpsController::TotpChallengeForm.new(token: "000000")
    user = Struct.new(:id, :user_secrets).new(1, FakeSecretRelation.new([Struct.new(:name).new("ABCD-secret")]))
    @controller.instance_variable_set(:@totp_form, form)

    Rails.event.stub :notify, nil do
      @controller.handle_totp_failure(user)
    end

    assert_includes form.errors[:token], "translated:sign.app.authentication.totp.invalid"
    rendered = @controller.instance_variable_get(:@_test_rendered)

    assert_equal [:new], rendered[:args]
    assert_equal :unprocessable_content, rendered[:status]
    assert_equal %w(ABCD), @controller.instance_variable_get(:@secret_hints)
  end
end
