# frozen_string_literal: true

# Template A (ID Only)
neyo_id_only = %w(
  com_timeline_audit_levels
  org_document_audit_events
  org_document_audit_levels
  org_timeline_audit_events
  org_timeline_audit_levels
  staff_identity_audit_events
  staff_identity_audit_levels
  staff_occurrence_statuses
  user_identity_audit_events
  user_identity_audit_levels
  user_occurrence_statuses
  user_token_statuses
  domain_occurrence_statuses
  org_contact_audit_events
  org_contact_audit_levels
)

active_id_only = %w(
  staff_identity_passkey_statuses
  staff_identity_secret_statuses
  user_identity_passkey_statuses
  user_identity_social_apple_statuses
  user_identity_social_google_statuses
)

# Template B (Full Status)
neyo_full = %w(
  org_document_statuses
  com_document_statuses
  app_document_statuses
  com_timeline_statuses
  org_timeline_statuses
)

neyo_id_content = <<~YAML
  neyo:
    id: NEYO
YAML

active_id_content = <<~YAML
  active:
    id: ACTIVE
YAML

neyo_full_content = <<~YAML
  neyo:
    id: NEYO
    description: Default Status
    active: true
    position: 0
YAML

def write_fixture(table, content)
  path = File.join(Dir.pwd, "test/fixtures/00_#{table}.yml")
  header = <<~YAML
    _fixture:
      table_name: #{table}

  YAML
  File.write(path, header + content)
  puts "Created #{path}"
end

neyo_id_only.each { |t| write_fixture(t, neyo_id_content) }
active_id_only.each { |t| write_fixture(t, active_id_content) }
neyo_full.each { |t| write_fixture(t, neyo_full_content) }
