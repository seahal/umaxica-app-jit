# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
# Database name: avatar
#
#  id                    :string           not null, primary key
#  body                  :text             not null
#  published_at          :timestamptz
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  author_avatar_id      :string           not null
#  created_by_actor_id   :string           not null
#  post_status_id        :string           not null
#  public_id             :string           not null
#  published_by_actor_id :string
#
# Indexes
#
#  index_posts_on_author_avatar_id_and_created_at  (author_avatar_id,created_at DESC)
#  index_posts_on_post_status_id                   (post_status_id)
#  index_posts_on_public_id                        (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (author_avatar_id => avatars.id)
#  fk_rails_...  (post_status_id => post_statuses.id)
#

class Post < AvatarRecord
  include PublicId

  belongs_to :author_avatar, class_name: "Avatar", inverse_of: :posts
  belongs_to :post_status

  has_many :post_reviews, dependent: :restrict_with_error, inverse_of: :post
  has_many :post_versions, dependent: :delete_all, inverse_of: :post

  validates :public_id, presence: true, uniqueness: true
  validates :body, presence: true
  validates :created_by_actor_id, presence: true
  validates :id, length: { maximum: 255 }

  def latest_version
    post_versions.order(created_at: :desc).first!
  end
end
