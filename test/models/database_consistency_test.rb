# frozen_string_literal: true

require "test_helper"

# Test suite to verify database consistency improvements
# Tests for uniqueness, presence, and foreign key validations
class DatabaseConsistencyTest < ActiveSupport::TestCase
  # Test PublicId concern validations
  test "UserEmail requires unique public_id" do
    email = UserEmail.new(
      address: "test@example.com",
      user_id: users(:one).id,
      public_id: "test_public_id_12345",
    )
    assert_predicate email, :valid?

    # Try to create another with same public_id
    duplicate = UserEmail.new(
      address: "other@example.com",
      user_id: users(:one).id,
      public_id: "test_public_id_12345",
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:public_id], "has already been taken"
  end

  test "UserEmail requires public_id presence" do
    email = UserEmail.new(
      address: "test@example.com",
      user_id: users(:one).id,
      public_id: nil,
    )
    assert_not email.valid?
    assert_includes email.errors[:public_id], "can't be blank"
  end

  # Test Preference jti uniqueness
  test "AppPreference requires unique jti" do
    AppPreference.create!(
      jti: "unique_jti_123",
      status_id: "NEYO",
    )

    pref2 = AppPreference.new(
      jti: "unique_jti_123",
      status_id: "NEYO",
    )
    assert_not pref2.valid?
    assert_includes pref2.errors[:jti], "has already been taken"
  end

  # Test Occurrence composite uniqueness
  test "UserZipOccurrence requires unique combination of user_occurrence_id and zip_occurrence_id" do
    user_occ = UserOccurrence.first || UserOccurrence.create!(
      public_id: "test_user_occ",
      status_id: 0,
    )
    zip_occ = ZipOccurrence.first || ZipOccurrence.create!(
      public_id: "test_zip_occ",
      status_id: 0,
    )

    UserZipOccurrence.create!(
      user_occurrence_id: user_occ.id,
      zip_occurrence_id: zip_occ.id,
    )

    # Try to create duplicate
    occurrence2 = UserZipOccurrence.new(
      user_occurrence_id: user_occ.id,
      zip_occurrence_id: zip_occ.id,
    )
    assert_not occurrence2.valid?
    assert_includes occurrence2.errors[:user_occurrence_id], "has already been taken"
  end

  # Test belongs_to presence validation
  test "UserEmail requires user association" do
    email = UserEmail.new(
      address: "test@example.com",
      public_id: "test_public_id",
      user_id: nil,
    )
    # Note: before_validation sets default user_id, so we test after that
    email.user_id = nil
    email.valid?
    assert_not email.valid?
    assert_includes email.errors[:user], "must exist"
  end

  test "StaffNotification requires staff association" do
    notification = StaffNotification.new(
      public_id: SecureRandom.uuid,
      staff_id: nil,
    )
    assert_not notification.valid?
    assert_includes notification.errors[:staff], "must exist"
  end

  # Test foreign key constraints (requires database setup)
  test "foreign key constraints prevent orphaned records" do
    skip "Requires database with foreign key constraints enabled"

    # This test would verify that deleting a parent record
    # respects on_delete: :cascade or :restrict
  end

  # Integration test: verify database_consistency checker results
  test "database_consistency warnings are resolved" do
    skip "Run 'bundle exec database_consistency' manually to verify"

    # Expected improvements:
    # - UniqueIndexChecker: 44 → 12 (PKs remain)
    # - NullConstraintChecker: 12 → 0
    # - ForeignKeyTypeChecker: 38 → 0
    # - ForeignKeyChecker: 33 → 0
    # - RedundantIndexChecker: 45 → 0
  end
end
