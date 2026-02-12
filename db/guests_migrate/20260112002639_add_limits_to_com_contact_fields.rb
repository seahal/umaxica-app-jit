# frozen_string_literal: true

class AddLimitsToComContactFields < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      change_column :com_contact_audits, :actor_type, :string, limit: 255
      change_column :com_contact_audits, :level_id, :string, limit: 255
      change_column :com_contact_emails, :hotp_secret, :string, limit: 255
      change_column :com_contact_telephones, :hotp_secret, :string, limit: 255
      change_column :com_contact_topics, :description, :text, limit: 4096
      change_column :com_contact_topics, :title, :string, limit: 255
    end
  end

  def down
    safety_assured do
      change_column :com_contact_audits, :actor_type, :string, limit: nil
      change_column :com_contact_audits, :level_id, :string, limit: nil
      change_column :com_contact_emails, :hotp_secret, :string, limit: nil
      change_column :com_contact_telephones, :hotp_secret, :string, limit: nil
      change_column :com_contact_topics, :description, :text, limit: nil
      change_column :com_contact_topics, :title, :string, limit: nil
    end
  end
end
