# frozen_string_literal: true

class CreateClientAvatarSuspensions < ActiveRecord::Migration[8.2]
  def change
    create_table :client_avatar_suspensions, id: :uuid do |t|
      t.references :client, null: false, foreign_key: { to_table: :clients }, type: :uuid
      t.references :avatar, null: false, foreign_key: { to_table: :avatars, primary_key: :id }, type: :string

      t.timestamps

      t.index %i(client_id avatar_id), unique: true, name: "index_client_avatar_suspensions_on_client_and_avatar"
    end
  end
end
