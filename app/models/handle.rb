# frozen_string_literal: true

# == Schema Information
#
# Table name: handles
#
#  id               :string           not null, primary key
#  public_id        :string           not null
#  handle           :string           not null
#  is_system        :boolean          default(FALSE), not null
#  cooldown_until   :timestamptz      not null
#  handle_status_id :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_handles_on_cooldown_until    (cooldown_until)
#  index_handles_on_handle_status_id  (handle_status_id)
#  index_handles_on_is_system         (is_system)
#  index_handles_on_public_id         (public_id) UNIQUE
#  uniq_handles_handle_non_system     (handle) UNIQUE
#

class Handle < IdentitiesRecord
  include StringPrimaryKey
  include PublicId

  belongs_to :handle_status, optional: true

  has_many :handle_assignments, dependent: :restrict_with_error
  has_many :avatars, through: :handle_assignments
  has_many :active_avatars,
           class_name: "Avatar",
           foreign_key: "active_handle_id",
           inverse_of: :active_handle,
           dependent: :restrict_with_error

  validates :public_id, presence: true, uniqueness: true
  validates :handle, presence: true,
                     uniqueness: { conditions: -> { where(is_system: false) } },
                     unless: :is_system?
  validates :cooldown_until, presence: true
end
