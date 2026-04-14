# typed: false
# frozen_string_literal: true

require "test_helper"

class ReferenceTableValidationTest < ActiveSupport::TestCase
  fixtures :app_document_behavior_events,
           :app_document_behavior_levels,
           :app_documents,
           :app_preference_activities,
           :app_preference_activity_events,
           :app_preference_activity_levels,
           :app_preference_binding_methods,
           :app_preference_dbsc_statuses,
           :app_preference_statuses,
           :app_preferences,
           :app_timeline_behavior_events,
           :app_timeline_behavior_levels,
           :app_timelines,
           :area_occurrence_statuses,
           :member_statuses,
           :scavenger_global_events,
           :scavenger_global_statuses,
           :user_activity_events,
           :user_activity_levels,
           :user_statuses,
           :user_token_binding_methods,
           :user_token_dbsc_statuses,
           :user_token_kinds,
           :user_token_statuses,
           :user_visibilities

  test "user rejects unknown status_id and visibility_id before database write" do
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: 999_991,
      visibility_id: 999_992,
    )

    assert_invalid_reference(user, :status_id, "user_status")
    assert_invalid_reference(user, :visibility_id, "visibility")
  end

  test "member rejects unknown status_id before database write" do
    member = Member.new(status_id: 999_993)

    assert_invalid_reference(member, :status_id, "member_status")
  end

  test "area occurrence rejects unknown status_id before database write" do
    occurrence = AreaOccurrence.new(
      body: "JP/Test/#{SecureRandom.hex(4)}",
      status_id: 999_994,
    )

    assert_invalid_reference(occurrence, :status_id, "area_occurrence_status")
  end

  test "app preference rejects unknown lookup ids before database write" do
    preference = AppPreference.new(
      status_id: 999_995,
      binding_method_id: 999_996,
      dbsc_status_id: 999_997,
      replaced_by_id: 999_998,
    )

    assert_invalid_reference(preference, :status_id, "app_preference_status")
    assert_invalid_reference(preference, :binding_method_id, "app_preference_binding_method")
    assert_invalid_reference(preference, :dbsc_status_id, "app_preference_dbsc_status")
    assert_invalid_reference(preference, :replaced_by_id, "replaced_by")
  end

  test "user token rejects unknown lookup ids before database write" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    token = UserToken.new(
      user: user,
      refresh_expires_at: 1.day.from_now,
      user_token_status_id: 999_999,
      user_token_kind_id: 999_998,
      user_token_binding_method_id: 999_997,
      user_token_dbsc_status_id: 999_996,
    )

    assert_invalid_reference(token, :user_token_status_id, "user_token_status")
    assert_invalid_reference(token, :user_token_kind_id, "user_token_kind")
    assert_invalid_reference(token, :user_token_binding_method_id, "user_token_binding_method")
    assert_invalid_reference(token, :user_token_dbsc_status_id, "user_token_dbsc_status")
  end

  test "user activity rejects unknown event_id and level_id before database write" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    activity = UserActivity.new(
      user: user,
      event_id: 999_995,
      level_id: 999_994,
      timestamp: Time.current,
    )

    assert_invalid_reference(activity, :event_id, "user_activity_event")
    assert_invalid_reference(activity, :level_id, "user_activity_level")
  end

  test "app preference activity rejects unknown event_id and level_id before database write" do
    preference = app_preferences(:one)
    activity = AppPreferenceActivity.new(
      subject_id: preference.id,
      subject_type: "AppPreference",
      event_id: 999_993,
      level_id: 999_992,
    )

    assert_invalid_reference(activity, :event_id, "app_preference_activity_event")
    assert_invalid_reference(activity, :level_id, "app_preference_activity_level")
  end

  test "app document behavior rejects unknown event_id and level_id before database write" do
    document = app_documents(:one)
    behavior = AppDocumentBehavior.new(
      subject_id: document.id,
      subject_type: "AppDocument",
      event_id: 999_991,
      level_id: 999_990,
    )

    assert_invalid_reference(behavior, :event_id, "app_document_behavior_event")
    assert_invalid_reference(behavior, :level_id, "app_document_behavior_level")
  end

  test "app timeline behavior rejects unknown event_id and level_id before database write" do
    timeline = app_timelines(:one)
    behavior = AppTimelineBehavior.new(
      subject_id: timeline.id,
      subject_type: "AppTimeline",
      event_id: 999_989,
      level_id: 999_988,
    )

    assert_invalid_reference(behavior, :event_id, "app_timeline_behavior_event")
    assert_invalid_reference(behavior, :level_id, "app_timeline_behavior_level")
  end

  test "scavenger global rejects unknown event_id and status_id before database write" do
    scavenger = ScavengerGlobal.new(
      job_type: "scavenger:global:test",
      idempotency_key: "global-#{SecureRandom.hex(8)}",
      event_id: 999_987,
      status_id: 999_986,
    )

    assert_invalid_reference(scavenger, :event_id, "scavenger_global_event")
    assert_invalid_reference(scavenger, :status_id, "scavenger_global_status")
  end

  test "app document rejects unknown status_id before database write" do
    document = AppDocument.new(
      slug_id: "test_#{SecureRandom.hex(8)}",
      permalink: "/test/#{SecureRandom.hex(8)}",
      status_id: 999_985,
    )

    assert_invalid_reference(document, :status_id, "app_document_status")
  end

  test "com document rejects unknown status_id before database write" do
    document = ComDocument.new(
      slug_id: "test_#{SecureRandom.hex(8)}",
      permalink: "/test/#{SecureRandom.hex(8)}",
      status_id: 999_984,
    )

    assert_invalid_reference(document, :status_id, "com_document_status")
  end

  test "org document rejects unknown status_id before database write" do
    document = OrgDocument.new(
      slug_id: "test_#{SecureRandom.hex(8)}",
      permalink: "/test/#{SecureRandom.hex(8)}",
      status_id: 999_983,
    )

    assert_invalid_reference(document, :status_id, "org_document_status")
  end

  test "user social google rejects unknown status_id before database write" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    social = UserSocialGoogle.new(
      user: user,
      token: "test_token",
      uid: "uid_#{SecureRandom.hex(8)}",
      token_expires_at: 1.day.from_now.to_i,
      status_id: 999_982,
    )

    assert_invalid_reference(social, :status_id, "user_social_google_status")
  end

  test "user social apple rejects unknown status_id before database write" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    social = UserSocialApple.new(
      user: user,
      token: "test_token",
      uid: "uid_#{SecureRandom.hex(8)}",
      token_expires_at: 1.day.from_now.to_i,
      status_id: 999_981,
    )

    assert_invalid_reference(social, :status_id, "user_social_apple_status")
  end

  test "user passkey rejects unknown status_id before database write" do
    UserEmailStatus.find_or_create_by!(id: UserEmailStatus::VERIFIED)
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    UserEmail.create!(
      user: user,
      address: "test_#{SecureRandom.hex(6)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
      confirm_policy: "1",
    )
    passkey = UserPasskey.new(
      user: user,
      webauthn_id: "test_#{SecureRandom.hex(16)}",
      external_id: SecureRandom.uuid,
      public_key: "test_key_#{SecureRandom.hex(16)}",
      description: "Test passkey",
      status_id: 999_980,
    )

    assert_invalid_reference(passkey, :status_id, "status")
  end

  test "staff passkey rejects unknown status_id before database write" do
    StaffVisibility.find_or_create_by!(id: StaffVisibility::STAFF)
    StaffTelephoneStatus.find_or_create_by!(id: StaffTelephoneStatus::VERIFIED)
    staff = Staff.create!(
      public_id: Staff.generate_public_id,
      status_id: StaffStatus::NOTHING,
      visibility_id: StaffVisibility::STAFF,
    )
    StaffTelephone.create!(
      staff: staff,
      number: "+15551234567",
      staff_telephone_status_id: StaffTelephoneStatus::VERIFIED,
    )
    passkey = StaffPasskey.new(
      staff: staff,
      webauthn_id: "test_#{SecureRandom.hex(16)}",
      external_id: SecureRandom.uuid,
      public_key: "test_key_#{SecureRandom.hex(16)}",
      name: "Test passkey",
      status_id: 999_979,
    )

    assert_invalid_reference(passkey, :status_id, "status")
  end

  test "app preference allows nil replaced_by_id" do
    preference = AppPreference.new(
      status_id: AppPreferenceStatus::NOTHING,
      binding_method_id: AppPreferenceBindingMethod::NOTHING,
      dbsc_status_id: AppPreferenceDbscStatus::NOTHING,
      replaced_by_id: nil,
    )

    assert_predicate preference, :valid?
  end

  # ============================================================================
  # Equivalence Partitioning - Data Type Validation
  # ============================================================================

  test "rejects string value for integer reference column" do
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: "not_an_integer",
      visibility_id: UserVisibility::STAFF,
    )

    assert_not user.valid?
    assert_not_empty user.errors[:status_id]
  end

  test "rejects float value for integer reference column" do
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: 1.5,
      visibility_id: UserVisibility::STAFF,
    )

    assert_not user.valid?
    assert_not_empty user.errors[:status_id]
  end

  test "rejects boolean true for integer reference column" do
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: true,
      visibility_id: UserVisibility::STAFF,
    )

    assert_not user.valid?
    assert_not_empty user.errors[:status_id]
  end

  test "rejects boolean false for integer reference column" do
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: false,
      visibility_id: UserVisibility::STAFF,
    )

    assert_not user.valid?
    assert_not_empty user.errors[:status_id]
  end

  # ============================================================================
  # Boundary Value Analysis
  # ============================================================================

  test "accepts valid status_id when reference exists" do
    # UserStatus::NOTHING = 11 is a valid reference
    UserStatus.find_or_create_by!(id: UserStatus::NOTHING)
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: UserStatus::NOTHING,
      visibility_id: UserVisibility::STAFF,
    )

    assert_predicate user, :valid?
  end

  test "rejects negative value for reference column" do
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: -1,
      visibility_id: UserVisibility::STAFF,
    )

    assert_not user.valid?
    assert_not_empty user.errors[:status_id]
  end

  test "rejects very large value beyond bigint range" do
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: 9_223_372_036_854_775_808, # Max bigint + 1
      visibility_id: UserVisibility::STAFF,
    )

    assert_not user.valid?
    assert_not_empty user.errors[:status_id]
  end

  # ============================================================================
  # Success Path - Valid Reference IDs
  # ============================================================================

  test "accepts valid status_id for user" do
    UserStatus.find_or_create_by!(id: UserStatus::NOTHING)
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: UserStatus::NOTHING,
      visibility_id: UserVisibility::STAFF,
    )

    assert_predicate user, :valid?
  end

  test "accepts valid visibility_id for user" do
    UserStatus.find_or_create_by!(id: UserStatus::NOTHING)
    UserVisibility.find_or_create_by!(id: UserVisibility::USER)
    user = User.new(
      public_id: "u_#{SecureRandom.hex(8)}",
      status_id: UserStatus::NOTHING,
      visibility_id: UserVisibility::USER,
    )

    assert_predicate user, :valid?
  end

  test "accepts valid reference ids for user token" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    token = UserToken.new(
      user: user,
      refresh_expires_at: 1.day.from_now,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      user_token_binding_method_id: UserTokenBindingMethod::NOTHING,
      user_token_dbsc_status_id: UserTokenDbscStatus::NOTHING,
    )

    assert_predicate token, :valid?
  end

  test "accepts valid reference ids for staff activity" do
    StaffActivityEvent.find_or_create_by!(id: 1)
    StaffActivityLevel.find_or_create_by!(id: 1)
    activity = StaffActivity.new(
      subject_id: 1,
      subject_type: "Staff",
      event_id: 1,
      level_id: 1,
      occurred_at: Time.current,
      expires_at: 1.day.from_now,
    )

    assert_predicate activity, :valid?
  end

  # ============================================================================
  # Optional Reference - nil handling
  # ============================================================================

  test "user occurrence rejects nil status_id due to presence validation" do
    UserOccurrenceStatus.find_or_create_by!(id: 0)
    occurrence = UserOccurrence.new(
      public_id: "uo_#{SecureRandom.alphanumeric(19)}",
      body: "test_body_#{SecureRandom.hex(8)}",
      status_id: nil,
    )

    # Occurrence concern has validates :status_id, presence: true
    assert_not occurrence.valid?
    assert_not_empty occurrence.errors[:status_id]
  end

  test "area occurrence rejects nil status_id due to presence validation" do
    AreaOccurrenceStatus.find_or_create_by!(id: 0)
    occurrence = AreaOccurrence.new(
      public_id: "ao_#{SecureRandom.alphanumeric(19)}",
      body: "JP/Test/#{SecureRandom.hex(4)}",
      status_id: nil,
    )

    # Occurrence concern has validates :status_id, presence: true
    assert_not occurrence.valid?
    assert_not_empty occurrence.errors[:status_id]
  end

  test "user social google allows nil status_id when optional" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    social = UserSocialGoogle.new(
      user: user,
      token: "test_token",
      uid: "uid_#{SecureRandom.hex(8)}",
      token_expires_at: 1.day.from_now.to_i,
      status_id: nil,
    )

    assert_predicate social, :valid?
  end

  test "user social apple allows nil status_id when optional" do
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    social = UserSocialApple.new(
      user: user,
      token: "test_token",
      uid: "uid_#{SecureRandom.hex(8)}",
      token_expires_at: 1.day.from_now.to_i,
      status_id: nil,
    )

    assert_predicate social, :valid?
  end

  test "user passkey allows nil status_id when optional" do
    UserEmailStatus.find_or_create_by!(id: UserEmailStatus::VERIFIED)
    user = User.create!(public_id: "u_#{SecureRandom.hex(8)}")
    UserEmail.create!(
      user: user,
      address: "test_#{SecureRandom.hex(6)}@example.com",
      user_email_status_id: UserEmailStatus::VERIFIED,
      confirm_policy: "1",
    )
    passkey = UserPasskey.new(
      user: user,
      webauthn_id: "test_#{SecureRandom.hex(16)}",
      external_id: SecureRandom.uuid,
      public_key: "test_key_#{SecureRandom.hex(16)}",
      description: "Test passkey",
      status_id: nil,
    )

    assert_predicate passkey, :valid?
  end

  test "staff passkey allows nil status_id when optional" do
    StaffVisibility.find_or_create_by!(id: StaffVisibility::STAFF)
    StaffTelephoneStatus.find_or_create_by!(id: StaffTelephoneStatus::VERIFIED)
    staff = Staff.create!(
      public_id: Staff.generate_public_id,
      status_id: StaffStatus::NOTHING,
      visibility_id: StaffVisibility::STAFF,
    )
    StaffTelephone.create!(
      staff: staff,
      number: "+15551234567",
      staff_telephone_status_id: StaffTelephoneStatus::VERIFIED,
    )
    passkey = StaffPasskey.new(
      staff: staff,
      webauthn_id: "test_#{SecureRandom.hex(16)}",
      external_id: SecureRandom.uuid,
      public_key: "test_key_#{SecureRandom.hex(16)}",
      name: "Test passkey",
      status_id: nil,
    )

    assert_predicate passkey, :valid?
  end

  private

  def assert_invalid_reference(record, attribute, association_name)
    assert_not record.valid?
    assert_includes record.errors[attribute], "must reference an existing #{association_name}"
  end
end
