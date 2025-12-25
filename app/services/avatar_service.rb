class AvatarService
  SYSTEM_HANDLE_VALUE = "__unassigned__"

  def self.create_with_system_handle!(
    moniker:,
    capability_id:,
    owner_organization_id: nil,
    representing_organization_id: nil,
    image_data: {},
    avatar_status_id: nil,
    handle_status_id: nil,
    handle_assignment_status_id: nil,
    assigned_by_actor_id: nil,
    cooldown_until: nil
  )
    Avatar.transaction do
      system_handle = Handle.create!(
        handle: SYSTEM_HANDLE_VALUE,
        is_system: true,
        cooldown_until: cooldown_until || 1.week.from_now,
        handle_status_id: handle_status_id
      )

      avatar = Avatar.create!(
        moniker: moniker,
        capability_id: capability_id,
        owner_organization_id: owner_organization_id,
        representing_organization_id: representing_organization_id,
        image_data: image_data,
        avatar_status_id: avatar_status_id,
        active_handle_id: system_handle.id
      )

      HandleAssignment.create!(
        avatar: avatar,
        handle: system_handle,
        valid_from: Time.current,
        handle_assignment_status_id: handle_assignment_status_id,
        assigned_by_actor_id: assigned_by_actor_id
      )

      avatar
    end
  end
end
