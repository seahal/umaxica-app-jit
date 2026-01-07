# frozen_string_literal: true

class FixClientsForeignKey < ActiveRecord::Migration[8.2]
  def up
    # Remove existing FK
    if foreign_key_exists?(:clients, :client_statuses, column: :status_id)
      remove_foreign_key :clients, :client_statuses, column: :status_id
    end

    # Add constraint with CASCADE via SQL to avoid Rails adapter hang
    safety_assured do
      execute <<-SQL.squish
        ALTER TABLE clients
        ADD CONSTRAINT fk_rails_clients_client_statuses_cascade
        FOREIGN KEY (status_id)
        REFERENCES client_statuses (id)
        ON DELETE CASCADE;
      SQL
    end
  end

  def down
    execute "ALTER TABLE clients DROP CONSTRAINT IF EXISTS fk_rails_clients_client_statuses_cascade;"
    add_foreign_key :clients, :client_statuses, column: :status_id
  end
end
