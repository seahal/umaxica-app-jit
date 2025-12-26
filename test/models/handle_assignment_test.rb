# == Schema Information
#
# Table name: handle_assignments
#
#  id                          :string           not null, primary key
#  avatar_id                   :string           not null
#  handle_id                   :string           not null
#  valid_from                  :timestamptz      not null
#  valid_to                    :timestamptz      default("infinity"), not null
#  handle_assignment_status_id :string
#  assigned_by_actor_id        :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_handle_assignments_on_avatar_id                    (avatar_id) UNIQUE
#  index_handle_assignments_on_avatar_id_and_valid_from     (avatar_id,valid_from)
#  index_handle_assignments_on_handle_assignment_status_id  (handle_assignment_status_id)
#  index_handle_assignments_on_handle_id                    (handle_id) UNIQUE
#  index_handle_assignments_on_handle_id_and_valid_from     (handle_id,valid_from)
#

require "test_helper"

class HandleAssignmentTest < ActiveSupport::TestCase
  setup do
    unique_suffix = SecureRandom.hex(4)
    @capability = AvatarCapability.create!(key: "normal-#{unique_suffix}", name: "Normal")
    @system_handle = Handle.create!(
      handle: "__unassigned__#{unique_suffix}",
      is_system: true,
      cooldown_until: 1.week.from_now
    )
    @avatar = Avatar.create!(
      capability: @capability,
      moniker: "avatar-#{unique_suffix}",
      active_handle: @system_handle,
      image_data: {}
    )
  end

  test "valid_to defaults to infinity" do
    assignment = HandleAssignment.create!(
      avatar: @avatar,
      handle: @system_handle,
      valid_from: Time.current
    )

    valid_to = assignment.reload.valid_to
    assert_predicate valid_to, :present?
    assert valid_to.to_s == "infinity" || (valid_to.is_a?(Float) && valid_to == Float::INFINITY)
  end

  test "prevents multiple active assignments for the same handle" do
    HandleAssignment.create!(
      avatar: @avatar,
      handle: @system_handle,
      valid_from: Time.current
    )

    other_handle = Handle.create!(handle: "other-#{SecureRandom.hex(4)}", cooldown_until: 1.week.from_now)
    other_avatar = Avatar.create!(
      capability: @capability,
      moniker: "another-#{SecureRandom.hex(4)}",
      active_handle: other_handle,
      image_data: {}
    )

    assert_raises ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique do
      HandleAssignment.create!(
        avatar: other_avatar,
        handle: @system_handle,
        valid_from: Time.current
      )
    end
  end
end
