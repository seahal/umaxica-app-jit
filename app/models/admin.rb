# == Schema Information
#
# Table name: admins
#
#  id         :uuid             not null, primary key
#  public_id  :string
#  moniker    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  status_id  :string(255)      default("NEYO"), not null
#  staff_id   :uuid             not null
#
# Indexes
#
#  index_admins_on_public_id  (public_id) UNIQUE
#  index_admins_on_staff_id   (staff_id)
#  index_admins_on_status_id  (status_id)
#

# frozen_string_literal: true

class Admin < IdentitiesRecord
  include ::PublicId

  self.implicit_order_column = :created_at

  attribute :status_id, default: AdminIdentityStatus::NEYO

  validates :public_id, uniqueness: true, allow_nil: true
  validates :status_id, length: { maximum: 255 }

  belongs_to :admin_identity_status,
             foreign_key: :status_id,
             inverse_of: :admins
  belongs_to :staff, inverse_of: :admins
end
