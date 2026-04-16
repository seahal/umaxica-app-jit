# frozen_string_literal: true

class AddExplicitOwnerColumnsToSettingsPreferences < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Add explicit owner columns (nullable for migration safety)
      add_column(:settings_preferences, :user_id, :bigint, null: true)
      add_column(:settings_preferences, :staff_id, :bigint, null: true)
      add_column(:settings_preferences, :customer_id, :bigint, null: true)

      # Backfill data from polymorphic owner_type/owner_id
      execute(<<~SQL.squish)
        UPDATE settings_preferences
        SET user_id = owner_id
        WHERE owner_type = 'User'
      SQL

      execute(<<~SQL.squish)
        UPDATE settings_preferences
        SET staff_id = owner_id
        WHERE owner_type = 'Staff'
      SQL

      execute(<<~SQL.squish)
        UPDATE settings_preferences
        SET customer_id = owner_id
        WHERE owner_type = 'Customer'
      SQL

      # Add unique partial indexes for each owner column
      # These ensure one preference per owner while allowing NULLs
      add_index(
        :settings_preferences, :user_id,
        unique: true,
        where: "user_id IS NOT NULL",
        name: "index_settings_preferences_on_user_id_unique"
      )
      add_index(
        :settings_preferences, :staff_id,
        unique: true,
        where: "staff_id IS NOT NULL",
        name: "index_settings_preferences_on_staff_id_unique"
      )
      add_index(
        :settings_preferences, :customer_id,
        unique: true,
        where: "customer_id IS NOT NULL",
        name: "index_settings_preferences_on_customer_id_unique"
      )

      # Add check constraint for exactly-one-owner semantics
      # Allows exactly one of user_id, staff_id, customer_id to be non-NULL
      # Note: 0 is considered a valid "anonymous" owner_id
      add_check_constraint(
        :settings_preferences,
        "(user_id IS NOT NULL)::integer + (staff_id IS NOT NULL)::integer + (customer_id IS NOT NULL)::integer = 1",
        name: "chk_settings_preferences_exactly_one_owner"
      )

      # Make legacy owner columns nullable
      # These will be removed in a future migration after full rollout
      change_column_null(:settings_preferences, :owner_type, true)
      change_column_null(:settings_preferences, :owner_id, true)

      # Note: Foreign keys are intentionally omitted because this is a multi-database
      # architecture. The settings database cannot reference tables in the principal
      # database (users, staff, customers). Referential integrity is enforced at the
      # application level via model validations.
    end
  end

  def down
    safety_assured do
      # Restore NOT NULL constraint on legacy columns
      change_column_null(:settings_preferences, :owner_type, false)
      change_column_null(:settings_preferences, :owner_id, false)

      remove_check_constraint(:settings_preferences, name: "chk_settings_preferences_exactly_one_owner")
      remove_index(:settings_preferences, name: "index_settings_preferences_on_customer_id_unique")
      remove_index(:settings_preferences, name: "index_settings_preferences_on_staff_id_unique")
      remove_index(:settings_preferences, name: "index_settings_preferences_on_user_id_unique")
      remove_column(:settings_preferences, :customer_id)
      remove_column(:settings_preferences, :staff_id)
      remove_column(:settings_preferences, :user_id)
    end
  end
end
