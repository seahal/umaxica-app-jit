require "test_helper"

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
end
