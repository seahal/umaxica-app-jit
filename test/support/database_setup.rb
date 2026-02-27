# typed: false
# frozen_string_literal: true

# Manual database initialization for test environment.
# These values are often expected to exist by various tests.

ActiveSupport.on_load(:active_record) do
  ensure_ids =
    lambda do |model, ids|
      existing_ids = model.where(id: ids).pluck(:id)
      missing_ids = ids - existing_ids
      missing_ids.each { |id| model.create!(id: id) }
    end

  if defined?(UserActivityEvent)
    UserActivityEvent.ensure_defaults!
  end

  if defined?(UserActivityLevel)
    UserActivityLevel.ensure_defaults!
  end

  if defined?(StaffActivityLevel)
    ensure_ids.call(StaffActivityLevel, [StaffActivityLevel::NOTHING])
  end

  if defined?(StaffActivityEvent)
    ensure_ids.call(
      StaffActivityEvent,
      [
        StaffActivityEvent::STAFF_SECRET_CREATED,
        StaffActivityEvent::STAFF_SECRET_REMOVED,
        StaffActivityEvent::STAFF_SECRET_UPDATED,
        StaffActivityEvent::STEP_UP_VERIFIED,
      ],
    )
  end

  if defined?(AppPreferenceActivityLevel)
    ensure_ids.call(AppPreferenceActivityLevel, [AppPreferenceActivityLevel::INFO])
  end
  if defined?(AppPreferenceActivityEvent)
    AppPreferenceActivityEvent.ensure_defaults!
  end

  if defined?(ComPreferenceActivityLevel)
    ensure_ids.call(ComPreferenceActivityLevel, [ComPreferenceActivityLevel::INFO])
  end
  if defined?(ComPreferenceActivityEvent)
    ComPreferenceActivityEvent.ensure_defaults!
  end

  if defined?(OrgPreferenceActivityLevel)
    ensure_ids.call(OrgPreferenceActivityLevel, [OrgPreferenceActivityLevel::INFO])
  end
  if defined?(OrgPreferenceActivityEvent)
    OrgPreferenceActivityEvent.ensure_defaults!
  end
end
