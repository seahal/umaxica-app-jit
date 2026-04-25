# typed: false
# frozen_string_literal: true

class RemoveRedundantMemberIndexesAvatar < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  INDEXES = {
    member_avatar_deletions: :index_member_avatar_deletions_on_member_id,
    member_avatar_suspensions: :index_member_avatar_suspensions_on_member_id,
  }.freeze

  def up
    safety_assured do
      INDEXES.each do |table, index_name|
        remove_index(table, name: index_name, algorithm: :concurrently, if_exists: true)
      end
    end
  end

  def down
    safety_assured do
      INDEXES.each do |table, index_name|
        add_index(
          table, :member_id, name: index_name,
                             algorithm: :concurrently,
        ) unless index_exists?(
          table, :member_id,
          name: index_name,
        )
      end
    end
  end
end
