# frozen_string_literal: true

# Seed all status lookup tables with their fixed ID records.
# These tables act as enums - each row is identified by a fixed constant ID.
# Run with: bin/rails db:seed

# rubocop:disable I18n/RailsI18n/DecorateString
Rails.logger.debug "Seeding status tables..."
# rubocop:enable I18n/RailsI18n/DecorateString

# Helper to seed a status model from its constants
def seed_status(klass)
  constants = klass.constants.select { |c| klass.const_get(c).is_a?(Integer) }
  constants.each do |name|
    id = klass.const_get(name)
    klass.find_or_create_by!(id: id)
  end
  Rails.logger.debug { "  #{klass.name}: #{constants.size} records ensured" }
rescue => e
  Rails.logger.debug { "  #{klass.name}: SKIPPED (#{e.message})" }
end

def seed_token_kinds(klass, mapping)
  mapping.each do |id, code|
    record = klass.find_or_initialize_by(id: id)
    if record.new_record?
      record.code = code if record.respond_to?(:code=)
      record.save!
    elsif record.respond_to?(:code) && record.code.to_s.casecmp(code) != 0
      record.update!(code: code)
    end
  end
  Rails.logger.debug { "  #{klass.name}: #{mapping.size} records ensured" }
rescue => e
  Rails.logger.debug { "  #{klass.name}: SKIPPED (#{e.message})" }
end

# --- Principal database statuses ---
seed_status(UserStatus)
seed_status(UserEmailStatus)
seed_status(UserOneTimePasswordStatus)
seed_status(UserPasskeyStatus)
seed_status(UserSecretStatus)
seed_status(UserSocialAppleStatus)
seed_status(UserSocialGoogleStatus)
seed_status(UserTelephoneStatus)
seed_status(ClientStatus)

# --- Token database statuses ---
seed_status(UserTokenStatus)
seed_status(StaffTokenStatus)

# --- Token database kinds ---
seed_token_kinds(
  UserTokenKind,
  {
    UserTokenKind::BROWSER_WEB => "BROWSER_WEB",
    UserTokenKind::CLIENT_IOS => "CLIENT_IOS",
    UserTokenKind::CLIENT_ANDROID => "CLIENT_ANDROID",
  },
)
seed_token_kinds(
  StaffTokenKind,
  {
    StaffTokenKind::BROWSER_WEB => "BROWSER_WEB",
    StaffTokenKind::CLIENT_IOS => "CLIENT_IOS",
    StaffTokenKind::CLIENT_ANDROID => "CLIENT_ANDROID",
  },
)

# --- Operator database statuses ---
seed_status(AdminStatus)
seed_status(DepartmentStatus)
seed_status(DivisionStatus)
seed_status(OrganizationStatus)
seed_status(StaffStatus)
seed_status(StaffEmailStatus)
seed_status(StaffOneTimePasswordStatus)
seed_status(StaffPasskeyStatus)
seed_status(StaffSecretStatus)
seed_status(StaffTelephoneStatus)
seed_status(WorkspaceStatus)

# --- Avatar database statuses ---
seed_status(AvatarMembershipStatus)
seed_status(AvatarMonikerStatus)
seed_status(AvatarOwnershipStatus)
seed_status(HandleAssignmentStatus)
seed_status(HandleStatus)
seed_status(PostReviewStatus)
seed_status(PostStatus)

# --- Guest database statuses ---
seed_status(AppContactStatus)
seed_status(ComContactStatus)
seed_status(OrgContactStatus)

# --- Document database statuses ---
seed_status(AppDocumentStatus)
seed_status(ComDocumentStatus)
seed_status(OrgDocumentStatus)

# --- News database statuses ---
seed_status(AppTimelineStatus)
seed_status(ComTimelineStatus)
seed_status(OrgTimelineStatus)

# --- Preference database statuses ---
seed_status(AppPreferenceStatus)
seed_status(ComPreferenceStatus)
seed_status(OrgPreferenceStatus)

# --- Occurrence database statuses ---
seed_status(AreaOccurrenceStatus)
seed_status(DomainOccurrenceStatus)
seed_status(EmailOccurrenceStatus)
seed_status(IpOccurrenceStatus)
seed_status(StaffOccurrenceStatus)
seed_status(TelephoneOccurrenceStatus)
seed_status(UserOccurrenceStatus)
seed_status(ZipOccurrenceStatus)

Rails.logger.debug "Done!"
