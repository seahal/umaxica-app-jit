# frozen_string_literal: true

class CreateAvatarBlocks < ActiveRecord::Migration[8.2]
  def change
    create_table :avatar_blocks, id: :uuid do |t|
      t.references :blocker_avatar,
                   null: false,
                   foreign_key: { to_table: :avatars, validate: false },
                   type: :string
      t.references :blocked_avatar,
                   null: false,
                   foreign_key: { to_table: :avatars, validate: false },
                   type: :string
      t.string :reason
      t.datetime :expires_at

      t.timestamps
    end
  end
end
