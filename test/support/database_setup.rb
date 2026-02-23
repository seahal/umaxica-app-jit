# typed: false
# frozen_string_literal: true

# Manual database initialization for test environment.
# These values are often expected to exist by various tests.

ActiveSupport.on_load(:active_record) do
  if defined?(UserActivityEvent)
    UserActivityEvent.ensure_defaults!
    [
      UserActivityEvent::USER_SECRET_CREATED,
      UserActivityEvent::USER_SECRET_REMOVED,
      UserActivityEvent::USER_SECRET_UPDATED,
    ].each { |id| UserActivityEvent.find_or_create_by!(id: id) }
  end

  if defined?(UserActivityLevel)
    UserActivityLevel.ensure_defaults!
  end

  if defined?(StaffActivityLevel)
    StaffActivityLevel.find_or_create_by!(id: StaffActivityLevel::NEYO)
  end

  if defined?(StaffActivityEvent)
    [
      StaffActivityEvent::STAFF_SECRET_CREATED,
      StaffActivityEvent::STAFF_SECRET_REMOVED,
      StaffActivityEvent::STAFF_SECRET_UPDATED,
      StaffActivityEvent::STEP_UP_VERIFIED,
    ].each { |id| StaffActivityEvent.find_or_create_by!(id: id) }
  end

  if defined?(AppPreferenceActivityLevel)
    AppPreferenceActivityLevel.find_or_create_by!(id: AppPreferenceActivityLevel::INFO)
  end
  if defined?(AppPreferenceActivityEvent)
    AppPreferenceActivityEvent.ensure_defaults!
  end

  if defined?(ComPreferenceActivityLevel)
    ComPreferenceActivityLevel.find_or_create_by!(id: ComPreferenceActivityLevel::INFO)
  end
  if defined?(ComPreferenceActivityEvent)
    ComPreferenceActivityEvent.ensure_defaults!
  end

  if defined?(OrgPreferenceActivityLevel)
    OrgPreferenceActivityLevel.find_or_create_by!(id: OrgPreferenceActivityLevel::INFO)
  end
  if defined?(OrgPreferenceActivityEvent)
    OrgPreferenceActivityEvent.ensure_defaults!
  end
end
