# typed: false
# frozen_string_literal: true

class ConvertAllAvatarPksToBigint < ActiveRecord::Migration[8.2]
  def up
    # Enable citext extension if not already enabled
    enable_extension("citext") unless extension_enabled?("citext")

    # Drop all avatar tables with int/serial/string PKs
    drop_table(:handle_statuses, if_exists: true, force: :cascade)
    drop_table(:handle_assignment_statuses, if_exists: true, force: :cascade)
    drop_table(:post_statuses, if_exists: true, force: :cascade)
    drop_table(:post_review_statuses, if_exists: true, force: :cascade)
    drop_table(:avatar_roles, if_exists: true, force: :cascade)
    drop_table(:avatar_permissions, if_exists: true, force: :cascade)
    drop_table(:avatar_capabilities, if_exists: true, force: :cascade)
    drop_table(:avatar_ownership_statuses, if_exists: true, force: :cascade)
    drop_table(:avatar_moniker_statuses, if_exists: true, force: :cascade)
    drop_table(:avatar_membership_statuses, if_exists: true, force: :cascade)

    # Recreate all tables with bigint PK + code column
    create_table(:handle_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:handle_assignment_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:post_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:post_review_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:avatar_roles, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:avatar_permissions, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:avatar_capabilities, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:avatar_ownership_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:avatar_moniker_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end

    create_table(:avatar_membership_statuses, id: :bigint) do |t|
      t.citext(:code, null: false, index: { unique: true })
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration drops data and cannot be reversed"
  end
end
