# frozen_string_literal: true

# == Schema Information
#
# Table name: post_statuses
#
#  id         :string           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_post_statuses_on_key  (key) UNIQUE
#

class PostStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :posts, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
