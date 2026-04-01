# frozen_string_literal: true

class ConvertAllOccurrencePksToBigint < ActiveRecord::Migration[8.2]
  def up
    # Enable citext extension if not already enabled
    enable_extension("citext") unless extension_enabled?("citext")

    # Drop all occurrence tables with int/serial/string PKs
    drop_table(:area_occurrence_statuses, if_exists: true, force: :cascade)
    drop_table(:domain_occurrence_statuses, if_exists: true, force: :cascade)
    drop_table(:email_occurrence_statuses, if_exists: true, force: :cascade)
    drop_table(:ip_occurrence_statuses, if_exists: true, force: :cascade)
    drop_table(:staff_occurrence_statuses, if_exists: true, force: :cascade)
    drop_table(:telephone_occurrence_statuses, if_exists: true, force: :cascade)
    drop_table(:user_occurrence_statuses, if_exists: true, force: :cascade)
    drop_table(:zip_occurrence_statuses, if_exists: true, force: :cascade)

    # Recreate all tables with bigint PK + code column
    create_table(:area_occurrence_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:domain_occurrence_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:email_occurrence_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:ip_occurrence_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:staff_occurrence_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:telephone_occurrence_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:user_occurrence_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:zip_occurrence_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration drops data and cannot be reversed"
  end
end
