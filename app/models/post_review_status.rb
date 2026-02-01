# frozen_string_literal: true

# == Schema Information
#
# Table name: post_review_statuses
# Database name: avatar
#
#  id   :integer          not null, primary key
#  key  :string           not null
#  name :string           not null
#
# Indexes
#
#  index_post_review_statuses_on_key  (key) UNIQUE
#

class PostReviewStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :post_reviews, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
