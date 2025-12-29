# frozen_string_literal: true

# Load all models
Rails.application.eager_load!

targets = %w(
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
  org_document_statuses
  com_document_statuses
  app_document_statuses
  com_timeline_statuses
  org_timeline_statuses
  staff_identity_passkey_statuses
  staff_identity_secret_statuses
  user_identity_passkey_statuses
  user_identity_social_apple_statuses
  user_identity_social_google_statuses
)

targets.each do |t|
  model = ActiveRecord::Base.descendants.find { |m| m.table_name == t }
  if model
    puts "TABLE: #{t}"
    puts model.column_names.join(",")
  else
    puts "TABLE: #{t} - Model not found"
  end
end
