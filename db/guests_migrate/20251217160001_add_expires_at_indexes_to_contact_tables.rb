class AddExpiresAtIndexesToContactTables < ActiveRecord::Migration[8.2]
  TABLES = %i(
    app_contact_emails
    app_contact_telephones
    app_contact_topics
    com_contact_emails
    com_contact_telephones
    com_contact_topics
    org_contact_emails
    org_contact_telephones
    org_contact_topics
  ).freeze

  def up
    TABLES.each do |table|
      next unless column_exists?(table, :expires_at)

      add_index table, :expires_at, name: index_name_for(table), if_not_exists: true
    end
  end

  def down
    TABLES.each do |table|
      remove_index table, name: index_name_for(table), if_exists: true
    end
  end

  private

  def index_name_for(table)
    "index_#{table}_on_expires_at"
  end
end
