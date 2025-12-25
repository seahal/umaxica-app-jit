# == Schema Information
#
# Table name: post_reviews
#
#  id                    :string           not null, primary key
#  post_id               :string           not null
#  reviewer_actor_id     :string           not null
#  post_review_status_id :string           not null
#  comment               :text
#  decided_at            :timestamptz
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_post_reviews_on_post_id_and_reviewer_actor_id  (post_id,reviewer_actor_id) UNIQUE
#  index_post_reviews_on_post_review_status_id          (post_review_status_id)
#  index_post_reviews_on_reviewer_actor_id              (reviewer_actor_id)
#

class PostReview < IdentitiesRecord
  include StringPrimaryKey

  belongs_to :post
  belongs_to :post_review_status

  validates :post_id, uniqueness: { scope: :reviewer_actor_id }
  validates :reviewer_actor_id, presence: true
end
