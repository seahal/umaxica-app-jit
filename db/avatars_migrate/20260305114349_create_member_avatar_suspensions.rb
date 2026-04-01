# frozen_string_literal: true

class CreateMemberAvatarSuspensions < ActiveRecord::Migration[8.2]
  def change
    create_table(:member_avatar_suspensions) do |t|
      t.references(:member, null: false, type: :bigint)
      t.references(:avatar, null: false, foreign_key: { to_table: :avatars, primary_key: :id }, type: :bigint)

      t.timestamps

      t.index(%i(member_id avatar_id), unique: true)
    end

    add_foreign_key(:member_avatar_suspensions, :members, validate: false) if table_exists?(:members)
  end
end
