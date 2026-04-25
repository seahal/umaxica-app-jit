# frozen_string_literal: true

class CleanupTokenRefStrings < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      remove_column(:staff_token_kinds, :id_old_string)
      remove_column(:staff_token_statuses, :id_old_string)
      remove_column(:user_token_kinds, :id_old_string)
      remove_column(:user_token_statuses, :id_old_string)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
