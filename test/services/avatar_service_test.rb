# frozen_string_literal: true

require "test_helper"

class AvatarServiceTest < ActiveSupport::TestCase
  test "create_with_system_handle! creates avatar, system handle and assignment" do
    capability = avatar_capabilities(:normal)
    handle_status = handle_statuses(:active)
    assignment_status = handle_assignment_statuses(:active)

    assert_difference -> { Avatar.count }, 1 do
      assert_difference -> { Handle.count }, 1 do
        assert_difference -> { HandleAssignment.count }, 1 do
          AvatarService.create_with_system_handle!(
            moniker: "Test Moniker",
            capability_id: capability.id,
            handle_status_id: handle_status.id,
            handle_assignment_status_id: assignment_status.id,
          )
        end
      end
    end

    avatar = Avatar.last
    handle = Handle.last
    assignment = HandleAssignment.last

    assert_equal "Test Moniker", avatar.moniker
    assert_equal capability.id, avatar.capability_id
    assert_equal handle.id, avatar.active_handle_id

    assert_equal "__unassigned__", handle.handle
    assert_predicate handle, :is_system?
    assert_equal handle_status.id, handle.handle_status_id

    assert_equal avatar.id, assignment.avatar_id
    assert_equal handle.id, assignment.handle_id
    assert_equal assignment_status.id, assignment.handle_assignment_status_id
  end
end
