require "test_helper"

class Sign::Org::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = Staff.create!(staff_identity_status_id: StaffIdentityStatus::NONE)
    @headers = { "X-TEST-CURRENT-STAFF" => @staff.id }.freeze
  end

  test "should create withdrawal (soft delete)" do
    assert_nil @staff.withdrawn_at

    post sign_org_withdrawal_url, headers: @headers

    @staff.reload

    assert_not_nil @staff.withdrawn_at
    assert_redirected_to sign_org_root_url(regional_defaults)
  end

  test "should update withdrawal (recover)" do
    @staff.update!(withdrawn_at: Time.current)

    # X-TEST-CURRENT-STAFF bypasses the withdrawn check in Authentication::Staff for testing purposes
    patch sign_org_withdrawal_url, headers: @headers

    @staff.reload

    assert_nil @staff.withdrawn_at
    assert_redirected_to sign_org_root_url(regional_defaults)
  end

  test "should destroy withdrawal (hard delete)" do
    @staff.update!(withdrawn_at: Time.current)

    assert_difference("Staff.count", -1) do
      delete sign_org_withdrawal_url, headers: @headers
    end

    assert_redirected_to sign_org_root_url(regional_defaults)
  end

  private

  def regional_defaults
    PreferenceConstants::DEFAULT_PREFERENCES.transform_keys(&:to_sym)
  end
end
