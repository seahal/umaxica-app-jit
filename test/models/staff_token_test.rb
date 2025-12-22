require "test_helper"

# Covers refresh token behavior and session constraints for staff.
class StaffTokenTest < ActiveSupport::TestCase
  def setup
    @staff = staffs(:one)
    @token = StaffToken.create!(staff: @staff)
  end

  test "inherits from TokensRecord" do
    assert_operator StaffToken, :<, TokensRecord
  end

  test "belongs to staff" do
    association = StaffToken.reflect_on_association(:staff)

    assert_not_nil association
    assert_equal :belongs_to, association.macro
  end

  test "can be created with staff" do
    assert_not_nil @token
    assert_equal @staff.id, @token.staff_id
  end

  test "generates UUID id automatically" do
    assert_not_nil @token.id
    assert_equal 36, @token.id.length
    assert_match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/, @token.id)
  end

  test "has created_at timestamp" do
    assert_not_nil @token.created_at
    assert_kind_of Time, @token.created_at
  end

  test "has updated_at timestamp" do
    assert_not_nil @token.updated_at
    assert_kind_of Time, @token.updated_at
  end

  test "staff association loads staff correctly" do
    assert_equal @staff, @token.staff
    assert_equal @staff.id, @token.staff.id
  end

  test "can load one fixture" do
    token_one = staff_tokens(:one)

    assert_not_nil token_one
    assert_not_nil token_one.staff_id
  end

  test "can load two fixture" do
    token_two = staff_tokens(:two)

    assert_not_nil token_two
    assert_not_nil token_two.staff_id
  end

  test "timestamp is set on creation" do
    token = StaffToken.create!(staff: @staff)

    assert_not_nil token.created_at
    assert_not_nil token.updated_at
    assert_operator token.created_at, :<=, token.updated_at
  end

  test "timestamp updates on save" do
    original_updated_at = @token.updated_at
    sleep(0.1)
    @token.update!(updated_at: Time.current)

    assert_operator @token.updated_at, :>, original_updated_at
  end

  test "enforces maximum concurrent sessions per staff" do
    staff = Staff.create!(staff_identity_status: staff_identity_statuses(:none))
    StaffToken::MAX_SESSIONS_PER_STAFF.times do
      StaffToken.create!(staff: staff)
    end

    extra_token = StaffToken.new(staff: staff)

    assert_not extra_token.valid?
    assert_includes extra_token.errors[:base], "exceeds maximum concurrent sessions per staff (#{StaffToken::MAX_SESSIONS_PER_STAFF})"
  end

  test "refresh token digest updates and authenticates" do
    token = StaffToken.create!(staff: @staff)

    token.refresh_token = "verifier-value"
    token.save!

    assert_predicate token.refresh_token_digest, :present?
    assert token.authenticate_refresh_token("verifier-value")
    assert_not token.authenticate_refresh_token("wrong-value")
  end

  test "active state reflects revoked and expired refresh tokens" do
    token = StaffToken.create!(staff: @staff)

    assert_predicate token, :active?

    token.update!(revoked_at: Time.current)
    assert_predicate token, :revoked?
    assert_not token.active?

    token.update!(revoked_at: nil, refresh_expires_at: 1.day.ago)
    assert_predicate token, :expired_refresh?
    assert_not token.active?
  end

  test "rotate_refresh_token! updates digest and timestamps" do
    token = StaffToken.create!(staff: @staff)
    old_digest = token.refresh_token_digest

    new_token = token.rotate_refresh_token!

    assert_match(/\A#{token.public_id}\./, new_token)
    assert_not_equal old_digest, token.refresh_token_digest
    assert_predicate token.rotated_at, :present?
    assert_predicate token.last_used_at, :present?
  end

  test "parse_refresh_token splits public_id and verifier" do
    token = StaffToken.create!(staff: @staff)
    raw = token.rotate_refresh_token!

    public_id, verifier = StaffToken.parse_refresh_token(raw)

    assert_equal token.public_id, public_id
    assert_predicate verifier, :present?
  end
end
