# frozen_string_literal: true

# == Schema Information
#
# Table name: post_statuses
# Database name: avatar
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_post_statuses_on_id  (id) UNIQUE
#
class PostStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :posts, dependent: :restrict_with_error
end
