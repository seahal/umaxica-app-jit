# frozen_string_literal: true

neyo_id_only = %w(
  com_timeline_audit_levels
  org_contact_audit_events
  org_contact_audit_levels
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
  user_identity_statuses
)

active_id_only = %w(
  staff_identity_passkey_statuses
  staff_identity_secret_statuses
  user_identity_passkey_statuses
  user_identity_social_apple_statuses
  user_identity_social_google_statuses
  user_identity_secret_statuses
)

neyo_full = %w(
  org_document_statuses
  com_document_statuses
  app_document_statuses
  com_timeline_statuses
  org_timeline_statuses
  org_contact_categories
  org_contact_statuses
  com_contact_categories
  app_timeline_statuses
)

File.open("test/support/seed_data.rb", "w") do |f|
  f.puts "module SeedData"
  f.puts "  extend ActiveSupport::Concern"
  f.puts ""
  f.puts "  included do"
  f.puts "    setup :seed_reference_tables"
  f.puts "  end"
  f.puts ""
  f.puts "  def seed_reference_tables"

  f.puts "    # NEYO ID Only"
  neyo_id_only.each do |t|
    klass = t.classify
    # Use upsert to bypass validation and handle existence
    f.puts "    #{klass}.upsert({ id: 'NEYO' }, unique_by: :id)"
  end

  f.puts ""
  f.puts "    # ACTIVE ID Only"
  active_id_only.each do |t|
    klass = t.classify
    f.puts "    #{klass}.upsert({ id: 'ACTIVE' }, unique_by: :id)"
  end

  f.puts ""
  f.puts "    # NEYO Full (Description, Active, Position)"
  neyo_full.each do |t|
    klass = t.classify
    f.puts "    #{klass}.upsert({ id: 'NEYO', description: 'Default', active: true, position: 0 }, unique_by: :id)"
  end

  f.puts "  end"
  f.puts "end"
end
