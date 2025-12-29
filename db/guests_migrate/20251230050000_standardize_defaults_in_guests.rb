# frozen_string_literal: true

class StandardizeDefaultsInGuests < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      # Integers -> 0
      change_column_default :org_contact_emails, :remaining_views, from: 10, to: 0
      change_column_default :org_contact_emails, :verifier_attempts_left, from: 3, to: 0
      change_column_default :org_contact_telephones, :remaining_views, from: 10, to: 0
      change_column_default :org_contact_telephones, :verifier_attempts_left, from: 3, to: 0
      change_column_default :app_contact_telephones, :remaining_views, from: 10, to: 0
      change_column_default :app_contact_telephones, :verifier_attempts_left, from: 3, to: 0
      change_column_default :app_contact_emails, :remaining_views, from: 10, to: 0
      change_column_default :app_contact_emails, :verifier_attempts_left, from: 3, to: 0
      change_column_default :com_contact_emails, :remaining_views, from: 10, to: 0
      change_column_default :com_contact_emails, :verifier_attempts_left, from: 5, to: 0
      change_column_default :com_contact_telephones, :remaining_views, from: 10, to: 0
      change_column_default :com_contact_telephones, :verifier_attempts_left, from: 3, to: 0
      change_column_default :app_contact_topics, :remaining_views, from: 10, to: 0
      change_column_default :app_contact_topics, :otp_attempts_left, from: 3, to: 0
      change_column_default :com_contact_topics, :remaining_views, from: 10, to: 0
      change_column_default :com_contact_topics, :otp_attempts_left, from: 3, to: 0
      change_column_default :org_contact_topics, :remaining_views, from: 10, to: 0
      change_column_default :org_contact_topics, :otp_attempts_left, from: 3, to: 0

      # Strings -> ""
      change_column_default :app_contact_categories, :parent_id, from: "00000000-0000-0000-0000-000000000000", to: ""
      change_column_default :com_contact_statuses, :parent_id, from: "00000000-0000-0000-0000-000000000000", to: ""
      change_column_default :org_contact_statuses, :parent_id, from: "00000000-0000-0000-0000-000000000000", to: ""

      change_column_default :app_contacts, :status_id, from: "NEYO", to: ""
      change_column_default :app_contacts, :category_id, from: "NEYO", to: ""
      change_column_default :com_contacts, :status_id, from: "NEYO", to: ""
      change_column_default :com_contacts, :category_id, from: "NEYO", to: ""
      change_column_default :org_contacts, :status_id, from: "NEYO", to: ""
      change_column_default :org_contacts, :category_id, from: "NEYO", to: ""
    end
  end
end
