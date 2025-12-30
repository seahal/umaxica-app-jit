# frozen_string_literal: true

class ValidateAvatarForeignKeys < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :handle_assignments, :avatars, column: :avatar_id if column_exists?(
      :handle_assignments,
      :avatar_id,
    )
    validate_foreign_key :avatar_monikers, :avatars, column: :avatar_id if column_exists?(:avatar_monikers, :avatar_id)
    validate_foreign_key :avatar_memberships, :avatars, column: :avatar_id if column_exists?(
      :avatar_memberships,
      :avatar_id,
    )
    validate_foreign_key :avatar_ownership_periods, :avatars, column: :avatar_id if column_exists?(
      :avatar_ownership_periods, :avatar_id,
    )
    validate_foreign_key :avatar_assignments, :avatars, column: :avatar_id if column_exists?(
      :avatar_assignments,
      :avatar_id,
    )
    validate_foreign_key :posts, :avatars, column: :author_avatar_id if column_exists?(:posts, :author_avatar_id)
    validate_foreign_key :avatar_follows, :avatars, column: :follower_avatar_id if column_exists?(
      :avatar_follows,
      :follower_avatar_id,
    )
    validate_foreign_key :avatar_follows, :avatars, column: :followed_avatar_id if column_exists?(
      :avatar_follows,
      :followed_avatar_id,
    )
    validate_foreign_key :avatar_blocks, :avatars, column: :blocker_avatar_id if column_exists?(
      :avatar_blocks,
      :blocker_avatar_id,
    )
    validate_foreign_key :avatar_blocks, :avatars, column: :blocked_avatar_id if column_exists?(
      :avatar_blocks,
      :blocked_avatar_id,
    )
    validate_foreign_key :avatar_mutes, :avatars, column: :muter_avatar_id if column_exists?(
      :avatar_mutes,
      :muter_avatar_id,
    )
    validate_foreign_key :avatar_mutes, :avatars, column: :muted_avatar_id if column_exists?(
      :avatar_mutes,
      :muted_avatar_id,
    )
  end
end
