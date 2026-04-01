# typed: false
# frozen_string_literal: true

require "test_helper"

class StaffSecrets::DestroyTest < ActiveSupport::TestCase
  fixtures :staff_statuses, :staff_email_statuses, :staff_secret_statuses, :staffs

  setup do
    @staff = staffs(:one)
    StaffEmail.create!(
      staff: @staff,
      address: "secret-test-#{SecureRandom.hex(4)}@example.com",
      staff_email_status_id: StaffEmailStatus::VERIFIED,
    )
    @secret = StaffSecret.create!(
      staff: @staff,
      name: "Test Secret",
      password: StaffSecret.generate_raw_secret,
      staff_secret_status_id: StaffSecretStatus::ACTIVE,
    )
  end

  test "destroys staff secret" do
    assert_difference("StaffSecret.count", -1) do
      StaffSecrets::Destroy.call(actor: @staff, secret: @secret)
    end
  end

  test "creates StaffActivity audit" do
    assert_difference("StaffActivity.count", 1) do
      StaffSecrets::Destroy.call(actor: @staff, secret: @secret)
    end

    activity = StaffActivity.last

    assert_equal StaffActivityEvent::STAFF_SECRET_REMOVED, activity.event_id
    assert_equal @staff, activity.actor
    assert_equal @secret.id, activity.subject_id
  end
end
