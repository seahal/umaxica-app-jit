require "test_helper"

class HandleTest < ActiveSupport::TestCase
  setup do
    @handle = Handle.new(
      handle: "valid_handle",
      cooldown_until: Time.current,
    )
  end

  test "valid handle" do
    assert_predicate @handle, :valid?
    assert @handle.save
  end

  test "requires handle" do
    @handle.handle = nil
    assert_not @handle.valid?
    assert_not_empty @handle.errors[:handle]
  end

  test "requires cooldown_until" do
    @handle.cooldown_until = nil
    assert_not @handle.valid?
    assert_not_empty @handle.errors[:cooldown_until]
  end

  test "handle uniqueness for non-system" do
    Handle.create!(handle: "taken", cooldown_until: Time.current)
    duplicate = Handle.new(handle: "taken", cooldown_until: Time.current)
    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:handle]
  end

  test "public_id generation" do
    @handle.save!
    assert_not_nil @handle.public_id
  end
end
