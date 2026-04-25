# frozen_string_literal: true

class AddLimitsToComContactFields < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      change_column(:com_contact_histories, :actor_type, :string, limit: 255) if column_exists?(:com_contact_histories, :actor_type)
      change_column(:com_contact_emails, :hotp_secret, :string, limit: 255) if column_exists?(:com_contact_emails, :hotp_secret)
      change_column(:com_contact_telephones, :hotp_secret, :string, limit: 255) if column_exists?(:com_contact_telephones, :hotp_secret)
      change_column(:com_contact_topics, :description, :text, limit: 4096) if column_exists?(:com_contact_topics, :description)
      change_column(:com_contact_topics, :title, :string, limit: 255) if column_exists?(:com_contact_topics, :title)
    end
  end

  def down
    safety_assured do
      change_column(:com_contact_histories, :actor_type, :string, limit: nil) if column_exists?(:com_contact_histories, :actor_type)
      change_column(:com_contact_emails, :hotp_secret, :string, limit: nil) if column_exists?(:com_contact_emails, :hotp_secret)
      change_column(:com_contact_telephones, :hotp_secret, :string, limit: nil) if column_exists?(:com_contact_telephones, :hotp_secret)
      change_column(:com_contact_topics, :description, :text, limit: nil) if column_exists?(:com_contact_topics, :description)
      change_column(:com_contact_topics, :title, :string, limit: nil) if column_exists?(:com_contact_topics, :title)
    end
  end
end
