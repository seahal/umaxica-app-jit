# typed: false
# frozen_string_literal: true

class CreateClientAvatarExtractions < ActiveRecord::Migration[8.2]
  def change
    create_table(:client_avatar_extractions) do |t|
      t.references(:client, null: false, type: :bigint)
      t.references(:avatar, null: false, foreign_key: { to_table: :avatars, primary_key: :id }, type: :string)

      t.timestamps

      t.index(%i(client_id avatar_id), unique: true, name: "index_client_avatar_extractions_on_client_and_avatar")
    end

    add_foreign_key(:client_avatar_extractions, :clients, validate: false) if table_exists?(:clients)
  end
end
