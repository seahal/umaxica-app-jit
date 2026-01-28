# frozen_string_literal: true

class CreateAvatarFollows < ActiveRecord::Migration[8.2]
  def change
    create_table :avatar_follows, id: :uuid do |t|
      t.references :follower_avatar,
                   null: false,
                   foreign_key: { to_table: :avatars, validate: false },
                   type: :string
      t.references :followed_avatar,
                   null: false,
                   foreign_key: { to_table: :avatars, validate: false },
                   type: :string

      t.timestamps
    end
  end
end
