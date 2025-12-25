# == Schema Information
#
# Table name: post_review_statuses
#
#  id          :string           not null, primary key
#  key         :string           not null
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_post_review_statuses_on_key  (key) UNIQUE
#

class PostReviewStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :post_reviews, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
