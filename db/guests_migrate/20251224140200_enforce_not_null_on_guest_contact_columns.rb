class EnforceNotNullOnGuestContactColumns < ActiveRecord::Migration[8.2]
  INFINITY_PAST = '-infinity'
  NIL_UUID = '00000000-0000-0000-0000-000000000000'

  def change
    # contact_categories: parent_id
    %w(app_contact_categories com_contact_categories org_contact_categories).each do |table|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET parent_id = '' WHERE parent_id IS NULL"
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_null :parent_id, false, ''
        t.change_default :parent_id, from: nil, to: ''
      end
    end

    reversible do |dir|
      dir.up do
        execute "UPDATE app_contact_statuses SET parent_title = '' WHERE parent_title IS NULL"
      end
    end

    change_table :app_contact_statuses, bulk: true do |t|
      t.change_null :parent_title, false, ''
      t.change_default :parent_title, from: nil, to: ''
    end

    # com_contact_statuses, org_contact_statuses: parent_id
    %w(com_contact_statuses org_contact_statuses).each do |table|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET parent_id = '' WHERE parent_id IS NULL"
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_null :parent_id, false, ''
        t.change_default :parent_id, from: nil, to: ''
      end
    end

    # app_contact_emails: token_digest, token_expires_at, verifier_digest, verifier_expires_at
    reversible do |dir|
      dir.up do
        execute "UPDATE app_contact_emails SET token_digest = '' WHERE token_digest IS NULL"
        execute "UPDATE app_contact_emails SET token_expires_at = '#{INFINITY_PAST}' WHERE token_expires_at IS NULL"
        execute "UPDATE app_contact_emails SET verifier_digest = '' WHERE verifier_digest IS NULL"
        execute "UPDATE app_contact_emails SET verifier_expires_at = '#{INFINITY_PAST}' WHERE verifier_expires_at IS NULL"
      end
    end

    change_table :app_contact_emails, bulk: true do |t|
      t.change_null :token_digest, false, ''
      t.change_default :token_digest, from: nil, to: ''

      t.change_null :token_expires_at, false, INFINITY_PAST
      t.change_default :token_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }

      t.change_null :verifier_digest, false, ''
      t.change_default :verifier_digest, from: nil, to: ''

      t.change_null :verifier_expires_at, false, INFINITY_PAST
      t.change_default :verifier_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
    end

    # app_contact_telephones: verifier_digest, verifier_expires_at
    reversible do |dir|
      dir.up do
        execute "UPDATE app_contact_telephones SET verifier_digest = '' WHERE verifier_digest IS NULL"
        execute "UPDATE app_contact_telephones SET verifier_expires_at = '#{INFINITY_PAST}' WHERE verifier_expires_at IS NULL"
      end
    end

    change_table :app_contact_telephones, bulk: true do |t|
      t.change_null :verifier_digest, false, ''
      t.change_default :verifier_digest, from: nil, to: ''

      t.change_null :verifier_expires_at, false, INFINITY_PAST
      t.change_default :verifier_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
    end

    # org_contact_telephones: verifier_digest, verifier_expires_at
    reversible do |dir|
      dir.up do
        execute "UPDATE org_contact_telephones SET verifier_digest = '' WHERE verifier_digest IS NULL"
        execute "UPDATE org_contact_telephones SET verifier_expires_at = '#{INFINITY_PAST}' WHERE verifier_expires_at IS NULL"
      end
    end

    change_table :org_contact_telephones, bulk: true do |t|
      t.change_null :verifier_digest, false, ''
      t.change_default :verifier_digest, from: nil, to: ''

      t.change_null :verifier_expires_at, false, INFINITY_PAST
      t.change_default :verifier_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
    end

    # app_contact_topics: otp_digest, otp_expires_at
    reversible do |dir|
      dir.up do
        execute "UPDATE app_contact_topics SET otp_digest = '' WHERE otp_digest IS NULL"
        execute "UPDATE app_contact_topics SET otp_expires_at = '#{INFINITY_PAST}' WHERE otp_expires_at IS NULL"
      end
    end

    change_table :app_contact_topics, bulk: true do |t|
      t.change_null :otp_digest, false, ''
      t.change_default :otp_digest, from: nil, to: ''

      t.change_null :otp_expires_at, false, INFINITY_PAST
      t.change_default :otp_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
    end

    # org_contact_topics: otp_digest, otp_expires_at
    reversible do |dir|
      dir.up do
        execute "UPDATE org_contact_topics SET otp_digest = '' WHERE otp_digest IS NULL"
        execute "UPDATE org_contact_topics SET otp_expires_at = '#{INFINITY_PAST}' WHERE otp_expires_at IS NULL"
      end
    end

    change_table :org_contact_topics, bulk: true do |t|
      t.change_null :otp_digest, false, ''
      t.change_default :otp_digest, from: nil, to: ''

      t.change_null :otp_expires_at, false, INFINITY_PAST
      t.change_default :otp_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
    end

    # com_contact_emails: hotp_counter, hotp_secret, token_digest, token_expires_at, verifier_digest, verifier_expires_at
    reversible do |dir|
      dir.up do
        execute "UPDATE com_contact_emails SET hotp_counter = 0 WHERE hotp_counter IS NULL"
        execute "UPDATE com_contact_emails SET hotp_secret = '' WHERE hotp_secret IS NULL"
        execute "UPDATE com_contact_emails SET token_digest = '' WHERE token_digest IS NULL"
        execute "UPDATE com_contact_emails SET token_expires_at = '#{INFINITY_PAST}' WHERE token_expires_at IS NULL"
        execute "UPDATE com_contact_emails SET verifier_digest = '' WHERE verifier_digest IS NULL"
        execute "UPDATE com_contact_emails SET verifier_expires_at = '#{INFINITY_PAST}' WHERE verifier_expires_at IS NULL"
      end
    end

    change_table :com_contact_emails, bulk: true do |t|
      t.change_null :hotp_counter, false, 0
      t.change_default :hotp_counter, from: nil, to: 0

      t.change_null :hotp_secret, false, ''
      t.change_default :hotp_secret, from: nil, to: ''

      t.change_null :token_digest, false, ''
      t.change_default :token_digest, from: nil, to: ''

      t.change_null :token_expires_at, false, INFINITY_PAST
      t.change_default :token_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }

      t.change_null :verifier_digest, false, ''
      t.change_default :verifier_digest, from: nil, to: ''

      t.change_null :verifier_expires_at, false, INFINITY_PAST
      t.change_default :verifier_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
    end

    # com_contact_telephones: hotp_counter, hotp_secret, verifier_digest, verifier_expires_at
    reversible do |dir|
      dir.up do
        execute "UPDATE com_contact_telephones SET hotp_counter = 0 WHERE hotp_counter IS NULL"
        execute "UPDATE com_contact_telephones SET hotp_secret = '' WHERE hotp_secret IS NULL"
        execute "UPDATE com_contact_telephones SET verifier_digest = '' WHERE verifier_digest IS NULL"
        execute "UPDATE com_contact_telephones SET verifier_expires_at = '#{INFINITY_PAST}' WHERE verifier_expires_at IS NULL"
      end
    end

    change_table :com_contact_telephones, bulk: true do |t|
      t.change_null :hotp_counter, false, 0
      t.change_default :hotp_counter, from: nil, to: 0

      t.change_null :hotp_secret, false, ''
      t.change_default :hotp_secret, from: nil, to: ''

      t.change_null :verifier_digest, false, ''
      t.change_default :verifier_digest, from: nil, to: ''

      t.change_null :verifier_expires_at, false, INFINITY_PAST
      t.change_default :verifier_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
    end

    # com_contact_topics: otp_digest, otp_expires_at
    reversible do |dir|
      dir.up do
        execute "UPDATE com_contact_topics SET otp_digest = '' WHERE otp_digest IS NULL"
        execute "UPDATE com_contact_topics SET otp_expires_at = '#{INFINITY_PAST}' WHERE otp_expires_at IS NULL"
      end
    end

    change_table :com_contact_topics, bulk: true do |t|
      t.change_null :otp_digest, false, ''
      t.change_default :otp_digest, from: nil, to: ''

      t.change_null :otp_expires_at, false, INFINITY_PAST
      t.change_default :otp_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
    end

    # app/com/org_contacts: contact_category_title, contact_status_id, ip_address, token_digest, token_expires_at
    %w(app_contacts com_contacts org_contacts).each do |table|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET contact_category_title = '' WHERE contact_category_title IS NULL"
          execute "UPDATE #{table} SET contact_status_id = '' WHERE contact_status_id IS NULL"
          execute "UPDATE #{table} SET ip_address = '0.0.0.0'::inet WHERE ip_address IS NULL"
          execute "UPDATE #{table} SET token_digest = '' WHERE token_digest IS NULL"
          execute "UPDATE #{table} SET token_expires_at = '#{INFINITY_PAST}' WHERE token_expires_at IS NULL"
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_null :contact_category_title, false, ''
        t.change_default :contact_category_title, from: nil, to: ''

        t.change_null :contact_status_id, false, ''
        t.change_default :contact_status_id, from: nil, to: ''

        t.change_null :ip_address, false, '0.0.0.0'
        t.change_default :ip_address, from: nil, to: -> { "'0.0.0.0'::inet" }

        t.change_null :token_digest, false, ''
        t.change_default :token_digest, from: nil, to: ''

        t.change_null :token_expires_at, false, INFINITY_PAST
        t.change_default :token_expires_at, from: nil, to: -> { "'-infinity'::timestamp" }
      end
    end

    # app_contact_histories, com_contact_audits, org_contact_histories: actor_id, actor_type, parent_id
    audit_tables = %w(app_contact_histories com_contact_audits org_contact_histories)
    audit_tables.each do |table|
      reversible do |dir|
        dir.up do
          execute "UPDATE #{table} SET actor_id = '#{NIL_UUID}' WHERE actor_id IS NULL"
          execute "UPDATE #{table} SET actor_type = '' WHERE actor_type IS NULL"
          execute "UPDATE #{table} SET parent_id = '#{NIL_UUID}' WHERE parent_id IS NULL"
        end
      end

      change_table table.to_sym, bulk: true do |t|
        t.change_null :actor_id, false, NIL_UUID
        t.change_default :actor_id, from: nil, to: NIL_UUID

        t.change_null :actor_type, false, ''
        t.change_default :actor_type, from: nil, to: ''

        t.change_null :parent_id, false, NIL_UUID
        t.change_default :parent_id, from: nil, to: NIL_UUID
      end
    end
  end
end
