# frozen_string_literal: true

class AddClientIdToAvatars < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      unless column_exists?(:avatars, :client_id)
        add_column :avatars, :client_id, :uuid
        add_index :avatars, :client_id
      end

      add_foreign_key :avatars, :clients, validate: false if table_exists?(:clients)
    end
  end
end
