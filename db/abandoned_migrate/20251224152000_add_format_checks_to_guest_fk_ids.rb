# frozen_string_literal: true

class AddFormatChecksToGuestFkIds < ActiveRecord::Migration[8.2]
  def change
    safety_assured { add_check_constraint(:app_contact_histories, "event_id IS NULL OR event_id ~ '^[A-Z0-9_]+$'", name: "chk_app_contact_histories_event_id_format", validate: false) }
    safety_assured { add_check_constraint(:app_contact_histories, "level_id IS NULL OR level_id ~ '^[A-Z0-9_]+$'", name: "chk_app_contact_histories_level_id_format", validate: false) }
    safety_assured { add_check_constraint(:app_contacts, "contact_status_id ~ '^[A-Z0-9_]+$'", name: "chk_app_contacts_contact_status_id_format", validate: false) }
    safety_assured { add_check_constraint(:com_contacts, "contact_status_id ~ '^[A-Z0-9_]+$'", name: "chk_com_contacts_contact_status_id_format", validate: false) }
    safety_assured { add_check_constraint(:org_contacts, "contact_status_id ~ '^[A-Z0-9_]+$'", name: "chk_org_contacts_contact_status_id_format", validate: false) }
  end
end
