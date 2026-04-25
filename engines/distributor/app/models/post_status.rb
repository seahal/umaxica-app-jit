# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: post_statuses
# Database name: avatar
#
#  id :bigint           not null, primary key
#
class PostStatus < AvatarRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NOTHING = 1
  ACTIVE = 2
  INACTIVE = 3
  DELETED = 4

  has_many :posts, dependent: :restrict_with_error
end
