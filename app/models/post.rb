# == Schema Information
#
# Table name: posts
#
#  id                    :string           not null, primary key
#  public_id             :string           not null
#  author_avatar_id      :string           not null
#  post_status_id        :string           not null
#  body                  :text             not null
#  created_by_actor_id   :string           not null
#  published_by_actor_id :string
#  published_at          :timestamptz
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_posts_on_author_avatar_id_and_created_at  (author_avatar_id,created_at)
#  index_posts_on_post_status_id                   (post_status_id)
#  index_posts_on_public_id                        (public_id) UNIQUE
#

class Post < IdentitiesRecord
  include StringPrimaryKey
  include PublicId

  belongs_to :author_avatar, class_name: "Avatar", inverse_of: :posts
  belongs_to :post_status

  has_many :post_reviews, dependent: :restrict_with_error

  validates :public_id, presence: true, uniqueness: true
  validates :body, presence: true
  validates :created_by_actor_id, presence: true
end
