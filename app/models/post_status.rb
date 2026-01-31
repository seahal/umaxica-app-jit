# frozen_string_literal: true

# == Schema Information
#
# Table name: post_statuses
# Database name: avatar
#
#  id :string           not null, primary key
#
class PostStatus < AvatarRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :posts, dependent: :restrict_with_error
end
