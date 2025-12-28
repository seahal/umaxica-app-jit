# frozen_string_literal: true

module FixtureAccessors
  ACCESSOR_CLASSES = %w(
    UserTokenStatus StaffTokenStatus
    ComDocumentStatus OrgDocumentStatus
    AppTimelineStatus ComTimelineStatus OrgTimelineStatus
    AreaOccurrenceStatus DomainOccurrenceStatus EmailOccurrenceStatus IpOccurrenceStatus
    StaffOccurrenceStatus TelephoneOccurrenceStatus UserOccurrenceStatus ZipOccurrenceStatus
    StaffIdentityStatus UserIdentityStatus
    UserIdentityEmailStatus UserIdentityOneTimePasswordStatus UserIdentityPasskeyStatus
    UserIdentitySecretStatus UserIdentitySocialAppleStatus UserIdentitySocialGoogleStatus
    UserIdentityTelephoneStatus
    StaffIdentityEmailStatus StaffIdentityPasskeyStatus StaffIdentitySecretStatus StaffIdentityTelephoneStatus
    UserIdentityAuditEvent UserIdentityAuditLevel StaffIdentityAuditEvent StaffIdentityAuditLevel
  )

  ACCESSOR_CLASSES.each do |class_name|
    next unless Object.const_defined?(class_name)

    klass = Object.const_get(class_name)
    method_name = klass.table_name

    define_method(method_name) do |key|
      # Support finding by ID (key)
      # If key is a symbol, convert to string
      # Attempt to look up assuming key matches ID (common pattern for Statuses)
      klass.find_by(id: key.to_s) || raise(ActiveRecord::RecordNotFound, "Could not find #{class_name} with id=#{key}")
    end
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include FixtureAccessors
end
