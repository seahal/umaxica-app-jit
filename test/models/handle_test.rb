# frozen_string_literal: true

# == Schema Information
#
# Table name: handles
#
#  id               :string           not null, primary key
#  public_id        :string           default(""), not null
#  handle           :string           not null
#  is_system        :boolean          default(FALSE), not null
#  cooldown_until   :timestamptz      not null
#  handle_status_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_handles_on_cooldown_until    (cooldown_until)
#  index_handles_on_handle_status_id  (handle_status_id)
#  index_handles_on_is_system         (is_system)
#  index_handles_on_public_id         (public_id) UNIQUE
#  uniq_handles_handle_non_system     (handle) UNIQUE
#

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

  test "handle is invalid when empty" do
    @handle.handle = ""
    assert_not @handle.valid?
    assert_not_empty @handle.errors[:handle]
  end

  test "handle is invalid when only whitespace" do
    @handle.handle = "   "
    assert_not @handle.valid?
    assert_not_empty @handle.errors[:handle]
  end

  test "public_id uniqueness" do
    @handle.save!
    duplicate = Handle.new(
      handle: "new_handle",
      cooldown_until: Time.current,
      public_id: @handle.public_id,
    )
    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:public_id]
  end

  test "association deletion: restriction by active_avatars" do
    @handle.save!
    capability = AvatarCapability.find_or_create_by!(key: "handle_test_cap", name: "Test Cap")
    Avatar.create!(
      moniker: "Avatar with Handle",
      active_handle: @handle,
      capability: capability,
    )

    assert_not @handle.destroy
    assert_includes @handle.errors[:base], "active avatarsが存在しているので削除できません"
  end
end
