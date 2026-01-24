# frozen_string_literal: true

# == Schema Information
#
# Table name: divisions
# Database name: operator
#
#  id                 :uuid             not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  division_status_id :string(255)      not null
#  organization_id    :uuid
#  parent_id          :uuid
#
# Indexes
#
#  index_divisions_on_division_status_id  (division_status_id)
#  index_divisions_on_organization_id     (organization_id)
#  index_divisions_unique                 (parent_id,division_status_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (division_status_id => division_statuses.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (parent_id => divisions.id)
#

class Division < OperatorRecord
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
