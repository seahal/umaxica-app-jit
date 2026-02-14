# frozen_string_literal: true

require "test_helper"

class ExpireOccurrencesJobTest < ActiveJob::TestCase
  test "marks old active occurrences as expired and keeps recent active records" do
    UserOccurrenceStatus.find_or_create_by!(id: UserOccurrence::EXPIRED_STATUS_ID)
    StaffOccurrenceStatus.find_or_create_by!(id: StaffOccurrence::EXPIRED_STATUS_ID)

    old_user = UserOccurrence.create!(
      body: SecureRandom.uuid,
      public_id: SecureRandom.urlsafe_base64(16).first(21),
      status_id: UserOccurrence::ACTIVE_STATUS_ID,
      created_at: 2.years.ago,
      updated_at: 2.years.ago,
    )
    recent_user = UserOccurrence.create!(
      body: SecureRandom.uuid,
      public_id: SecureRandom.urlsafe_base64(16).first(21),
      status_id: UserOccurrence::ACTIVE_STATUS_ID,
      created_at: 6.months.ago,
      updated_at: 6.months.ago,
    )
    old_staff = StaffOccurrence.create!(
      body: SecureRandom.uuid,
      public_id: SecureRandom.urlsafe_base64(16).first(21),
      status_id: StaffOccurrence::ACTIVE_STATUS_ID,
      created_at: 2.years.ago,
      updated_at: 2.years.ago,
    )

    ExpireOccurrencesJob.perform_now

    assert_equal UserOccurrence::EXPIRED_STATUS_ID, old_user.reload.status_id
    assert_equal UserOccurrence::ACTIVE_STATUS_ID, recent_user.reload.status_id
    assert_equal StaffOccurrence::EXPIRED_STATUS_ID, old_staff.reload.status_id
  end
end
