class ChangeAllDatetimeToTimestamptzInGuest < ActiveRecord::Migration[8.1]
  def up
    # corporate_site_contact_emails
    change_table :corporate_site_contact_emails, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # corporate_site_contact_telephones
    change_table :corporate_site_contact_telephones, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # corporate_site_contact_topics
    change_table :corporate_site_contact_topics, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # corporate_site_contacts
    change_table :corporate_site_contacts, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # service_site_contacts
    change_table :service_site_contacts, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end

    # staff_site_contacts
    change_table :staff_site_contacts, bulk: true do |t|
      t.change :created_at, :timestamptz, null: false
      t.change :updated_at, :timestamptz, null: false
    end
  end

  def down
    # Rollback: change back to datetime
    # corporate_site_contact_emails
    change_table :corporate_site_contact_emails, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # corporate_site_contact_telephones
    change_table :corporate_site_contact_telephones, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # corporate_site_contact_topics
    change_table :corporate_site_contact_topics, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # corporate_site_contacts
    change_table :corporate_site_contacts, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # service_site_contacts
    change_table :service_site_contacts, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end

    # staff_site_contacts
    change_table :staff_site_contacts, bulk: true do |t|
      t.change :created_at, :datetime, null: false
      t.change :updated_at, :datetime, null: false
    end
  end
end
