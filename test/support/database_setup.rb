# typed: false
# frozen_string_literal: true

# Manual database initialization for test environment.
# These values are often expected to exist by various tests.

ActiveSupport.on_load(:active_record) do
  Prosopite.pause do
    if defined?(UserActivityEvent)
      UserActivityEvent.ensure_defaults!
    end

    if defined?(UserActivityLevel)
      UserActivityLevel.ensure_defaults!
    end

    if defined?(StaffActivityLevel)
      StaffActivityLevel.insert_missing_fixed_ids!([StaffActivityLevel::NOTHING])
    end

    if defined?(StaffActivityEvent)
      StaffActivityEvent.ensure_defaults!
    end

    if defined?(AppPreferenceActivityLevel)
      AppPreferenceActivityLevel.ensure_defaults!
    end
    if defined?(AppPreferenceActivityEvent)
      AppPreferenceActivityEvent.ensure_defaults!
    end

    if defined?(ComPreferenceActivityLevel)
      ComPreferenceActivityLevel.ensure_defaults!
    end
    if defined?(ComPreferenceActivityEvent)
      ComPreferenceActivityEvent.ensure_defaults!
    end

    if defined?(OrgPreferenceActivityLevel)
      OrgPreferenceActivityLevel.ensure_defaults!
    end
    if defined?(OrgPreferenceActivityEvent)
      OrgPreferenceActivityEvent.ensure_defaults!
    end
  end
end
