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
      StaffActivityLevel.find_or_create_by!(id: StaffActivityLevel::NOTHING)
    end

    if defined?(StaffActivityEvent)
      StaffActivityEvent.ensure_defaults!
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
end
