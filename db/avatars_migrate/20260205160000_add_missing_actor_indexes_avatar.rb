# frozen_string_literal: true

class AddMissingActorIndexesAvatar < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_index :handle_assignments, :assigned_by_actor_id, algorithm: :concurrently, if_not_exists: true
    add_index :avatar_monikers, :set_by_actor_id, algorithm: :concurrently, if_not_exists: true
    add_index :avatar_memberships, :granted_by_actor_id, algorithm: :concurrently, if_not_exists: true
    add_index :avatar_ownership_periods, :transferred_by_actor_id, algorithm: :concurrently, if_not_exists: true

    add_index :post_versions, :edited_by_id, algorithm: :concurrently, if_not_exists: true
    add_index :posts, :created_by_actor_id, algorithm: :concurrently, if_not_exists: true
    add_index :posts, :published_by_actor_id, algorithm: :concurrently, if_not_exists: true
  end
end
