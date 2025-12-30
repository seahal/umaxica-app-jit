# frozen_string_literal: true

class CreateAvatarMutes < ActiveRecord::Migration[8.2]
  def change
    create_table :avatar_mutes, id: :uuid do |t|
      t.references :muter_avatar,
                   null: false,
                   foreign_key: { to_table: :avatars, validate: false },
                   type: :string
      t.references :muted_avatar,
                   null: false,
                   foreign_key: { to_table: :avatars, validate: false },
                   type: :string
      t.datetime :expires_at

      t.timestamps
    end
  end
end
