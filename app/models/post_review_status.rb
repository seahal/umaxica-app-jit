# frozen_string_literal: true

# == Schema Information
#
# Table name: post_review_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_post_review_statuses_on_code  (code) UNIQUE
#

class PostReviewStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :post_reviews, dependent: :restrict_with_error
end
