# frozen_string_literal: true

# == Schema Information
#
# Table name: avatars
#
#  id                           :string           not null, primary key
#  active_handle_id             :string           not null
#  avatar_status_id             :string
#  capability_id                :string           not null
#  created_at                   :datetime         not null
#  image_data                   :jsonb            default("{}"), not null
#  moniker                      :string           not null
#  owner_organization_id        :string
#  public_id                    :string           not null
#  representing_organization_id :string
#  updated_at                   :datetime         not null
#  lock_version                 :integer          default(0), not null
#
# Indexes
#
#  index_avatars_on_active_handle_id              (active_handle_id)
#  index_avatars_on_capability_id                 (capability_id)
#  index_avatars_on_owner_organization_id         (owner_organization_id)
#  index_avatars_on_public_id                     (public_id) UNIQUE
#  index_avatars_on_representing_organization_id  (representing_organization_id)
#

require "test_helper"

class AvatarTest < ActiveSupport::TestCase
  setup do
    @capability = AvatarCapability.create!(key: "user-#{SecureRandom.hex(4)}", name: "User")
    @handle = Handle.create!(
      handle: "test_handle-#{SecureRandom.hex(4)}",
      cooldown_until: Time.current,
    )
  end

  test "valid avatar creation" do
    avatar = Avatar.new(
      capability: @capability,
      active_handle: @handle,
      moniker: "Test User",
      image_data: { url: "http://example.com/img.png" },
    )
    assert_predicate avatar, :valid?
    assert avatar.save
    assert_not_nil avatar.public_id
  end

  test "requires capability" do
    avatar = Avatar.new(active_handle: @handle, moniker: "No Cap")
    assert_not avatar.valid?
    assert_not_empty avatar.errors[:capability]
  end

  test "requires active_handle" do
    avatar = Avatar.new(capability: @capability, moniker: "No Handle")
    assert_not avatar.valid?
    assert_not_empty avatar.errors[:active_handle]
  end

  test "requires moniker" do
    avatar = Avatar.new(capability: @capability, active_handle: @handle, moniker: "")
    assert_not avatar.valid?
    assert_not_empty avatar.errors[:moniker]
  end

  test "default image_data is empty hash" do
    avatar = Avatar.create!(
      capability: @capability,
      active_handle: @handle,
      moniker: "Default Image",
    )
    assert_empty(avatar.image_data)
  end

  test "unique public_id is generated" do
    avatar = Avatar.create!(
      capability: @capability,
      active_handle: @handle,
      moniker: "Public ID Test",
    )
    assert_not_nil avatar.public_id
  end
end
