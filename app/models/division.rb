# frozen_string_literal: true

# == Schema Information
#
# Table name: divisions
#
#  id                 :uuid             not null, primary key
#  division_status_id :string(255)      not null
#  parent_id          :uuid
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organization_id    :uuid
#
# Indexes
#
#  index_divisions_on_division_status_id  (division_status_id)
#  index_divisions_on_organization_id     (organization_id)
#  index_divisions_unique                 (parent_id,division_status_id) UNIQUE
#

class Division < IdentitiesRecord
  self.implicit_order_column = :created_at

  belongs_to :division_status,
             primary_key: :id,
             inverse_of: :divisions

  belongs_to :organization,
             class_name: "Organization",
             optional: true,
             inverse_of: :divisions
  has_many :clients,
           dependent: :nullify,
           inverse_of: :division

  validates :division_status_id,
            length: { maximum: 255 },
            uniqueness: { scope: :parent_id,
                          message: :already_tagged, }
end
