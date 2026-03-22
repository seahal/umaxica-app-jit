# frozen_string_literal: true

class FixAppContactStatusForeignKey < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      remove_foreign_key(:app_contacts, column: :status_id) if foreign_key_exists?(:app_contacts, column: :status_id)
      add_foreign_key(:app_contacts, :app_contact_statuses, column: :status_id, on_delete: :nullify)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
