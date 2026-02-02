# == Schema Information
#
# Table name: avatar_capabilities
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_avatar_capabilities_on_code  (code) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class AvatarCapabilityTest < ActiveSupport::TestCase
  setup do
    @capability = AvatarCapability.new(
      key: "test_cap",
      name: "Test Capability",
    )
  end

  test "valid capability" do
    assert_predicate @capability, :valid?
  end

  test "requires key" do
    @capability.key = nil
    assert_not @capability.valid?
    assert_not_empty @capability.errors[:key]
  end

  test "requires name" do
    @capability.name = nil
    assert_not @capability.valid?
    assert_not_empty @capability.errors[:name]
  end

  test "key uniqueness" do
    @capability.save!
    duplicate = AvatarCapability.new(key: @capability.key, name: "Other")
    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:key]
  end

  test "association deletion: restriction by avatars" do
    @capability.save!
    handle = Handle.create!(handle: "cap_test_handle", cooldown_until: Time.current)
    Avatar.create!(
      moniker: "Cap Test Avatar",
      active_handle: handle,
      capability: @capability,
    )

    assert_not @capability.destroy
    assert_includes @capability.errors[:base], "avatarsが存在しているので削除できません"
  end

  test "validates length of id" do
    record = AvatarCapability.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
