# frozen_string_literal: true

class AddIdFormatConstraintsToStringIdTables < ActiveRecord::Migration[8.2]
  # All tables with string IDs ending in Status/Event/Option/Level/Master/Category
  # These should only allow uppercase letters, numbers, and underscores

  def up
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id ~ '^[A-Z0-9_]+$')
        SQL
      end
    end
  end

  def down
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

  def tables_to_constrain
    [
      # User and Staff related statuses
      "user_token_statuses", "staff_token_statuses", "user_telephone_statuses",
      "user_statuses", "user_social_google_statuses", "user_social_apple_statuses",
      "user_secret_statuses", "user_passkey_statuses", "user_one_time_password_statuses",
      "user_email_statuses", "staff_telephone_statuses", "staff_statuses",
      "staff_secret_statuses", "staff_passkey_statuses", "staff_email_statuses",

      # Organization and Workspace
      "organization_statuses", "division_statuses", "workspace_statuses", "admin_statuses",

      # Posts and Content
      "post_statuses", "post_review_statuses", "handle_statuses",
      "handle_assignment_statuses", "client_statuses",

      # Avatar related
      "avatar_ownership_statuses", "avatar_moniker_statuses", "avatar_membership_statuses",

      # Occurrences
      "staff_occurrence_statuses", "user_occurrence_statuses", "zip_occurrence_statuses",
      "telephone_occurrence_statuses", "ip_occurrence_statuses", "email_occurrence_statuses",
      "domain_occurrence_statuses", "area_occurrence_statuses",

      # Timeline (org/com/app)
      "org_timeline_statuses", "org_timeline_tag_masters", "org_timeline_category_masters",
      "com_timeline_statuses", "com_timeline_tag_masters", "com_timeline_category_masters",
      "app_timeline_statuses", "app_timeline_tag_masters", "app_timeline_category_masters",

      # Document (org/com/app)
      "org_document_statuses", "org_document_tag_masters", "org_document_category_masters",
      "com_document_statuses", "com_document_tag_masters", "com_document_category_masters",
      "app_document_statuses", "app_document_tag_masters", "app_document_category_masters",

      # Contact (org/com/app)
      "org_contact_statuses", "org_contact_categories",
      "com_contact_statuses", "com_contact_categories",
      "app_contact_statuses", "app_contact_categories",

      # Audit (user/staff)
      "user_audit_levels", "user_audit_events",
      "staff_audit_levels", "staff_audit_events",

      # Audit - Timeline (org/com/app)
      "org_timeline_audit_levels", "org_timeline_audit_events",
      "com_timeline_audit_levels", "com_timeline_audit_events",
      "app_timeline_audit_levels", "app_timeline_audit_events",

      # Audit - Document (org/com/app)
      "org_document_audit_levels", "org_document_audit_events",
      "com_document_audit_levels", "com_document_audit_events",
      "app_document_audit_levels", "app_document_audit_events",
    ]
  end
end
