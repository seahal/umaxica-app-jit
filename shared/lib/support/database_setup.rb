# typed: false
# frozen_string_literal: true

# Manual database initialization for test environment.
# These values are often expected to exist by various tests.

ActiveSupport.on_load(:active_record) do
  Prosopite.pause do
    if defined?(UserActivityEvent) && UserActivityEvent.table_exists?
      UserActivityEvent.ensure_defaults!
    end

    if defined?(UserActivityLevel) && UserActivityLevel.table_exists?
      UserActivityLevel.ensure_defaults!
    end

    if defined?(StaffActivityLevel) && StaffActivityLevel.table_exists?
      StaffActivityLevel.insert_missing_fixed_ids!([StaffActivityLevel::NOTHING])
    end

    if defined?(StaffActivityEvent) && StaffActivityEvent.table_exists?
      StaffActivityEvent.ensure_defaults!
    end

    if defined?(AppPreferenceActivityLevel) && AppPreferenceActivityLevel.table_exists?
      AppPreferenceActivityLevel.ensure_defaults!
    end
    if defined?(AppPreferenceActivityEvent) && AppPreferenceActivityEvent.table_exists?
      AppPreferenceActivityEvent.ensure_defaults!
    end

    if defined?(ComPreferenceActivityLevel) && ComPreferenceActivityLevel.table_exists?
      ComPreferenceActivityLevel.ensure_defaults!
    end
    if defined?(ComPreferenceActivityEvent) && ComPreferenceActivityEvent.table_exists?
      ComPreferenceActivityEvent.ensure_defaults!
    end

    if defined?(OrgPreferenceActivityLevel) && OrgPreferenceActivityLevel.table_exists?
      OrgPreferenceActivityLevel.ensure_defaults!
    end
    if defined?(OrgPreferenceActivityEvent) && OrgPreferenceActivityEvent.table_exists?
      OrgPreferenceActivityEvent.ensure_defaults!
    end
  end
end
