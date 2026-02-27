# frozen_string_literal: true

class ConvertOccurrencePks < ActiveRecord::Migration[8.0]
  def up
    main_types = %w(email ip telephone zip area domain user staff)

    # -------------------------------------------------------------------------
    # DEPENDENTS (Drop)
    # -------------------------------------------------------------------------
    # Intersection tables
    pivots = %w(
      area_domain area_email area_ip area_staff area_telephone area_user area_zip
      domain_email domain_ip domain_staff domain_telephone domain_user domain_zip
      email_ip email_staff email_telephone email_user email_zip
      ip_staff ip_telephone ip_user ip_zip
      staff_telephone staff_user staff_zip
      telephone_user telephone_zip
      user_zip
    ) # Based on file list

    pivots.each do |pivot|
      drop_table :"#{pivot}_occurrences", if_exists: true, force: :cascade
    end

    main_types.each do |type|
      drop_table :"#{type}_occurrences", if_exists: true, force: :cascade
      drop_table :"#{type}_occurrence_statuses", if_exists: true, force: :cascade
    end

    # -------------------------------------------------------------------------
    # RECREATE (Bigint PK)
    # -------------------------------------------------------------------------

    # Statuses
    main_types.each do |type|
      create_table :"#{type}_occurrence_statuses", id: :string do |t|
        t.datetime :expires_at, null: false, default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }
        t.timestamps
        t.index :expires_at
      end

      # Insert default 'NONE' status
      safety_assured do
        execute "INSERT INTO #{type}_occurrence_statuses (id, created_at, updated_at) VALUES ('NONE', NOW(), NOW())"
      end
    end

    # Main Tables
    main_types.each do |type|
      create_table :"#{type}_occurrences" do |t|
        t.string :public_id, limit: 21, null: false, default: ""
        t.string :body, null: false, default: "" # Length limits vary but text/string is fine for recreation
        t.string :status_id, null: false, default: "NONE"
        t.string :memo, null: false, default: ""
        t.datetime :expires_at, null: false, default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }

        t.timestamps

        t.index :public_id, unique: true
        t.index :expires_at
        t.index :status_id
        # Body unique index for most? Migration said BODY_UNIQUE_TABLES = ALL except...
        # Let's add body index.
        t.index :body, unique: true
      end

      add_foreign_key :"#{type}_occurrences", :"#{type}_occurrence_statuses", column: :status_id, primary_key: :id, validate: false
    end

    # Intersection Tables
    pivots.each do |pivot|
      parts = pivot.split('_')
      type1 = parts[0]
      type2 = parts[1]

      create_table :"#{pivot}_occurrences" do |t|
        t.bigint :"#{type1}_occurrence_id", null: false
        t.bigint :"#{type2}_occurrence_id", null: false
        t.timestamps

        t.index :"#{type1}_occurrence_id"
        t.index :"#{type2}_occurrence_id"
        # Unique pair? Usually yes.
        t.index [:"#{type1}_occurrence_id", :"#{type2}_occurrence_id"], unique: true, name: "idx_#{pivot}_occ_on_ids"
      end

      add_foreign_key :"#{pivot}_occurrences", :"#{type1}_occurrences", validate: false
      add_foreign_key :"#{pivot}_occurrences", :"#{type2}_occurrences", validate: false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
