# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
#
#  id         :string           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_avatar_ownership_statuses_on_key  (key) UNIQUE
#

class AvatarOwnershipStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :avatar_ownership_periods, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
