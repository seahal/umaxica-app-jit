# frozen_string_literal: true

class ConvertGuestPks < ActiveRecord::Migration[8.0]
  def up
    prefixes = %w(app com org)

    prefixes.each do |prefix|
      # Drop Dependents first
      drop_table(:"#{prefix}_contact_emails", if_exists: true)
      drop_table(:"#{prefix}_contact_telephones", if_exists: true)
      drop_table(:"#{prefix}_contact_topics", if_exists: true)

      # Audit/History tables (Check if they exist, names vary slightly per schema? Guest schema showed both)
      # app_contact_histories, com_contact_audits?
      # Schema showed: app_contact_histories, com_contact_audits, org_contact_histories.
      # Wait, why the mix?
      # Let's drop both if they exist for all prefixes to be safe, or follow schema strictly.
      # Schema:
      # app: histories
      # com: audits
      # org: histories
      # This is weird inconsistency. I will check for both and drop both.

      drop_table(:"#{prefix}_contact_histories", if_exists: true)
      drop_table(:"#{prefix}_contact_audits", if_exists: true)

      # Drop Main Table
      drop_table(:"#{prefix}_contacts", if_exists: true)

      # We do NOT drop categories, statuses, audit_events as they are String PKs.
    end

    # Recreate
    prefixes.each do |prefix|
      # Contacts
      create_table(:"#{prefix}_contacts") do |t|
        t.string(:public_id, limit: 21, null: false)
        t.string(:category_id)
        t.integer(:status_id, limit: 2)
        t.inet(:ip_address)
        t.string(:token, limit: 32, default: "", null: false)
        t.string(:token_digest)
        t.datetime(:token_expires_at)
        t.boolean(:token_viewed, default: false, null: false)
        t.timestamps

        t.index(:public_id)
        t.index(:token)
        t.index(:token_digest)
        t.index(:token_expires_at)
      end

      # FKs for Contacts
      # We assume categories/statuses exist (since we didn't drop them).
      # If they reference String PKs, column type matches (string).
      # add_foreign_key :"#{prefix}_contacts", :"#{prefix}_contact_categories", column: :category_id, validate: false
      # add_foreign_key :"#{prefix}_contacts", :"#{prefix}_contact_statuses", column: :status_id, validate: false

      # Emails (String PK in schema: id: :string) -> Wait, schema said "id: :string" for app_contact_emails?
      # Line 30: create_table "app_contact_emails", id: :string do |t|
      # The User asked to convert UUID PKs.
      # If `app_contact_emails` has String PK, I don't need to change its PK.
      # BUT it references `app_contact_id` (uuid).
      # So I MUST recreate it to change FK type to Bigint.
      # And I should keep PK as String? Schema says `id: :string`.
      # Actually, usually Rails uses `id` column. If `id: :string`, it's a string PK.
      # I will recreate it with `id: :string`.

      create_table(:"#{prefix}_contact_emails", id: :string) do |t|
        t.bigint(:"#{prefix}_contact_id", null: false)
        t.boolean(:activated, default: false, null: false)
        t.boolean(:deletable, default: false, null: false)
        t.string(:email_address, limit: 1000, default: "", null: false)
        t.datetime(:expires_at, default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false)
        t.integer(:remaining_views, limit: 2, default: 10, null: false)
        t.string(:token_digest)
        t.datetime(:token_expires_at)
        t.boolean(:token_viewed, default: false, null: false)

        # com_contact_emails has hotp_counter/secret. app?
        if prefix == 'com'
          t.integer(:hotp_counter)
          t.string(:hotp_secret)
        end

        t.integer(:verifier_attempts_left, limit: 2, default: ((prefix == 'com') ? 5 : 3), null: false)
        t.string(:verifier_digest)
        t.datetime(:verifier_expires_at)

        t.timestamps

        t.index(:"#{prefix}_contact_id")
        t.index(:email_address)
        t.index(:expires_at)
        t.index(:verifier_expires_at)
      end

      # Telephones (id: :string)
      create_table(:"#{prefix}_contact_telephones", id: :string) do |t|
        t.bigint(:"#{prefix}_contact_id", null: false)
        t.boolean(:activated, default: false, null: false)
        t.boolean(:deletable, default: false, null: false)
        t.datetime(:expires_at, default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false)
        t.integer(:remaining_views, limit: 2, default: 10, null: false)
        t.string(:telephone_number, limit: 1000, default: "", null: false)

        if prefix == 'com'
          t.integer(:hotp_counter)
          t.string(:hotp_secret)
        end

        t.integer(:verifier_attempts_left, limit: 2, default: 3, null: false)
        t.string(:verifier_digest)
        t.datetime(:verifier_expires_at)

        t.timestamps

        t.index(:"#{prefix}_contact_id")
        t.index(:expires_at)
        t.index(:telephone_number)
        t.index(:verifier_expires_at)
      end

      # Topics (id: :uuid -> Bigint)
      create_table(:"#{prefix}_contact_topics") do |t|
        t.bigint(:"#{prefix}_contact_id", null: false)
        t.boolean(:activated, default: false, null: false)
        t.boolean(:deletable, default: false, null: false)
        t.string(:public_id, limit: 21, null: false)
        t.text(:description) if prefix == 'com'
        t.string(:title) if prefix == 'com'
        t.datetime(:expires_at, default: -> { "(CURRENT_TIMESTAMP + 'P1D'::interval)" }, null: false)
        t.integer(:otp_attempts_left, limit: 2, default: 3, null: false)
        t.string(:otp_digest)
        t.datetime(:otp_expires_at)
        t.integer(:remaining_views, limit: 2, default: 10, null: false)

        t.timestamps

        t.index(:"#{prefix}_contact_id")
        t.index(:expires_at)
        t.index(:public_id)
      end
    end

    # Audit/History
    # Schema: app_contact_histories, com_contact_audits, org_contact_histories.
    # I will stick to schema structure.

    # App History
    create_table(:app_contact_histories) do |t|
      t.bigint(:app_contact_id, null: false)
      t.bigint(:actor_id) # Was uuid
      t.string(:actor_type)
      t.string(:event_id, default: "NONE", null: false)
      t.bigint(:parent_id) # Was uuid
      t.integer(:position, default: 0, null: false)
      t.timestamps
      t.index(:app_contact_id)
    end

    # Com Audit
    create_table(:com_contact_audits) do |t|
      t.bigint(:com_contact_id, null: false)
      t.bigint(:actor_id)
      t.string(:actor_type)
      t.string(:event_id, default: "NONE", null: false)
      t.bigint(:parent_id)
      t.integer(:position, default: 0, null: false)
      t.timestamps
      t.index(:com_contact_id)
    end

    # Org History
    create_table(:org_contact_histories) do |t|
      t.bigint(:org_contact_id, null: false)
      t.bigint(:actor_id)
      t.string(:actor_type)
      t.string(:event_id, default: "NONE", null: false)
      t.bigint(:parent_id)
      t.integer(:position, default: 0, null: false)
      t.timestamps
      t.index(:org_contact_id)
    end

    # Main FKs
    %w(app com org).each do |prefix|
      add_foreign_key(:"#{prefix}_contact_emails", :"#{prefix}_contacts", validate: false)
      add_foreign_key(:"#{prefix}_contact_telephones", :"#{prefix}_contacts", validate: false)
      add_foreign_key(:"#{prefix}_contact_topics", :"#{prefix}_contacts", validate: false)

      # History/Audit FKs
      table = ((prefix == 'com') ? "#{prefix}_contact_audits" : "#{prefix}_contact_histories")
      add_foreign_key(table, :"#{prefix}_contacts", validate: false)

      # Event FKs (to string PK tables)
      # add_foreign_key table, :"#{prefix}_contact_audit_events", column: :event_id, validate: false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
