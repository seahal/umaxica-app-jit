# frozen_string_literal: true

module StatusSeeder
  SEEDED_KEY = :status_seeder_seeded

  def self.seed!
    # Only seed once per test run
    return if Thread.current[SEEDED_KEY]

    # UserTokenStatus (Only has ID)
    if defined?(UserTokenStatus)
      UserTokenStatus.find_or_create_by(id: "NEYO")
      UserTokenStatus.find_or_create_by(id: "NONE")
    end

    # StaffTokenStatus (Only has ID)
    if defined?(StaffTokenStatus)
      StaffTokenStatus.find_or_create_by(id: "NEYO")
      StaffTokenStatus.find_or_create_by(id: "NONE")
    end

    # ComDocumentStatus (Has id, description, active, position)
    if defined?(ComDocumentStatus)
      %w(ACTIVE DRAFT ARCHIVED NEYO NONE).each_with_index do |id, idx|
        ComDocumentStatus.find_or_create_by(id: id) do |s|
          s.description = id.titleize
          s.active = true
          s.position = idx + 1
        end
      end
    end

    # OrgDocumentStatus (Has id, description, active, position)
    if defined?(OrgDocumentStatus)
      %w(ACTIVE NONE).each_with_index do |id, idx|
        OrgDocumentStatus.find_or_create_by(id: id) do |s|
          s.description = id.titleize
          s.active = true
          s.position = idx + 1
        end
      end
    end

    # Timeline Statuses
    %w(
      AppTimelineStatus
      ComTimelineStatus
      OrgTimelineStatus
    ).each do |klass_name|
      if Object.const_defined?(klass_name)
        klass = Object.const_get(klass_name)
        %w(ACTIVE NONE).each_with_index do |id, idx|
          klass.find_or_create_by(id: id) do |s|
            s.description = id.titleize
            s.active = true
            s.position = idx + 1
          end
        end
      end
    end

    # Occurrence Statuses (Only have ID and expires_at)
    %w(
      AreaOccurrenceStatus
      DomainOccurrenceStatus
      EmailOccurrenceStatus
      IpOccurrenceStatus
      StaffOccurrenceStatus
      TelephoneOccurrenceStatus
      UserOccurrenceStatus
      ZipOccurrenceStatus
    ).each do |klass_name|
      if Object.const_defined?(klass_name)
        klass = Object.const_get(klass_name)
        klass.find_or_create_by(id: "ACTIVE")
        klass.find_or_create_by(id: "NONE")
      end
    end

    # Identity Statuses (Only have ID)
    identity_statuses = [
      "StaffIdentityStatus",
      "UserIdentityStatus",
      "UserIdentityEmailStatus",
      "UserIdentityKycStatus", # If exists
      "UserIdentityOneTimePasswordStatus",
      "UserIdentityPasskeyStatus",
      "UserIdentitySecretStatus",
      "UserIdentitySocialAppleStatus",
      "UserIdentitySocialGoogleStatus",
      "UserIdentityTelephoneStatus",
      "StaffIdentityEmailStatus",
      "StaffIdentityPasskeyStatus", # If exists
      "StaffIdentitySecretStatus",
      "StaffIdentityTelephoneStatus",
    ]

    identity_statuses.each do |klass_name|
      if Object.const_defined?(klass_name)
        klass = Object.const_get(klass_name)
        klass.find_or_create_by(id: "NEYO")
        klass.find_or_create_by(id: "ACTIVE")
        klass.find_or_create_by(id: "ALIVE")
        klass.find_or_create_by(id: "NONE")
        klass.find_or_create_by(id: "UNVERIFIED")
      end
    end

    # Audit Events/Levels
    if defined?(UserIdentityAuditEvent)
      UserIdentityAuditEvent.find_or_create_by(id: "NONE")
      UserIdentityAuditEvent.find_or_create_by(id: "login_success") # For tests
    end
    if defined?(UserIdentityAuditLevel)
      UserIdentityAuditLevel.find_or_create_by(id: "NONE")
      UserIdentityAuditLevel.find_or_create_by(id: "INFO")
    end
    if defined?(StaffIdentityAuditEvent)
      StaffIdentityAuditEvent.find_or_create_by(id: "NONE")
    end
    if defined?(StaffIdentityAuditLevel)
      StaffIdentityAuditLevel.find_or_create_by(id: "NONE")
    end

    Thread.current[SEEDED_KEY] = true
  end

  def self.reset!
    Thread.current[SEEDED_KEY] = false
  end
end

# Hook into ActiveSupport::TestCase to run seeding BEFORE fixtures are loaded
ActiveSupport.on_load(:active_support_test_case) do
  prepend Module.new {
    def before_setup
      StatusSeeder.seed!
      super
    end
  }
end
