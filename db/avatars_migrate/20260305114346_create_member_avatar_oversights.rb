# frozen_string_literal: true

class CreateMemberAvatarOversights < ActiveRecord::Migration[8.2]
  def change
    create_table(:member_avatar_oversights) do |t|
      t.bigint(:member_id, null: false)
      t.references(:avatar, null: false, foreign_key: { to_table: :avatars, primary_key: :id }, type: :bigint)

      t.timestamps

      t.index(%i(member_id avatar_id), unique: true)
    end
  end
end
