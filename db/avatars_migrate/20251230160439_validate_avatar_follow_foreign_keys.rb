# frozen_string_literal: true

class ValidateAvatarFollowForeignKeys < ActiveRecord::Migration[8.2]
  def change
    validate_foreign_key :avatar_follows, :avatars, column: :follower_avatar_id
    validate_foreign_key :avatar_follows, :avatars, column: :followed_avatar_id
  end
end
