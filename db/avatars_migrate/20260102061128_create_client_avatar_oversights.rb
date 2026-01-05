# frozen_string_literal: true

class CreateClientAvatarOversights < ActiveRecord::Migration[8.2]
  def change
    create_table :client_avatar_oversights, id: :uuid do |t|
      t.references :client, null: false, type: :uuid
      t.references :avatar, null: false, foreign_key: { to_table: :avatars, primary_key: :id }, type: :string

      t.timestamps

      t.index %i(client_id avatar_id), unique: true, name: "index_client_avatar_oversights_on_client_and_avatar"
    end

    add_foreign_key :client_avatar_oversights, :clients, validate: false if table_exists?(:clients)
  end
end
