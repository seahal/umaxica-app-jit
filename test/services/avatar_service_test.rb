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
          create_with_system_handle(
            capability: capability,
            handle_status: handle_status,
            assignment_status: assignment_status,
          )
        end
      end
    end
  end

  test "create_with_system_handle! sets avatar attributes" do
    capability = avatar_capabilities(:normal)
    handle_status = handle_statuses(:active)
    assignment_status = handle_assignment_statuses(:active)

    avatar, handle = create_with_system_handle(
      capability: capability,
      handle_status: handle_status,
      assignment_status: assignment_status,
    )

    assert_equal "Test Moniker", avatar.moniker
    assert_equal capability.id, avatar.capability_id
    assert_equal handle.id, avatar.active_handle_id
  end

  test "create_with_system_handle! sets handle attributes" do
    capability = avatar_capabilities(:normal)
    handle_status = handle_statuses(:active)
    assignment_status = handle_assignment_statuses(:active)

    _avatar, handle = create_with_system_handle(
      capability: capability,
      handle_status: handle_status,
      assignment_status: assignment_status,
    )

    assert_equal "__unassigned__", handle.handle
    assert_predicate handle, :is_system?
    assert_equal handle_status.id, handle.handle_status_id
  end

  test "create_with_system_handle! sets assignment attributes" do
    capability = avatar_capabilities(:normal)
    handle_status = handle_statuses(:active)
    assignment_status = handle_assignment_statuses(:active)

    avatar, handle, assignment = create_with_system_handle(
      capability: capability,
      handle_status: handle_status,
      assignment_status: assignment_status,
    )

    assert_equal avatar.id, assignment.avatar_id
    assert_equal handle.id, assignment.handle_id
    assert_equal assignment_status.id, assignment.handle_assignment_status_id
  end

  private

  def create_with_system_handle(capability:, handle_status:, assignment_status:)
    avatar = AvatarService.create_with_system_handle!(
      moniker: "Test Moniker",
      capability_id: capability.id,
      handle_status_id: handle_status.id,
      handle_assignment_status_id: assignment_status.id,
    )

    handle = avatar.active_handle
    assignment = avatar.handle_assignments.last

    [avatar, handle, assignment]
  end
end
