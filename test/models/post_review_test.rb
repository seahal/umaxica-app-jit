# frozen_string_literal: true

# == Schema Information
#
# Table name: post_reviews
# Database name: avatar
#
#  id                    :bigint           not null, primary key
#  comment               :text
#  decided_at            :timestamptz
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  post_id               :bigint           not null
#  post_review_status_id :integer          default(0), not null
#  reviewer_actor_id     :string           not null
#
# Indexes
#
#  index_post_reviews_on_post_id_and_reviewer_actor_id  (post_id,reviewer_actor_id) UNIQUE
#  index_post_reviews_on_post_review_status_id          (post_review_status_id)
#  index_post_reviews_on_reviewer_actor_id              (reviewer_actor_id) WHERE (decided_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (post_review_status_id => post_review_statuses.id)
#

require "test_helper"

class PostReviewTest < ActiveSupport::TestCase
  test "validations" do
    review = PostReview.new
    assert_not review.valid?
  end

  test "validates length of id" do
    record = PostReview.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
