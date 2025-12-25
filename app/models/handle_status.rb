# == Schema Information
#
# Table name: handle_statuses
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
#  index_handle_statuses_on_key  (key) UNIQUE
#

class HandleStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :handles, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
