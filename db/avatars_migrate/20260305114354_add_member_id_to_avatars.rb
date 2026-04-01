# frozen_string_literal: true

class AddMemberIdToAvatars < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      unless column_exists?(:avatars, :member_id)
        add_column(:avatars, :member_id, :bigint)
        add_index(:avatars, :member_id)
      end

      add_foreign_key(:avatars, :members, validate: false) if table_exists?(:members)
    end
  end
end
