# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: divisions
# Database name: operator
#
#  id                 :bigint           not null, primary key
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  division_status_id :bigint           default(0), not null
#  organization_id    :bigint
#
# Indexes
#
#  index_divisions_on_division_status_id_and_organization_id  (division_status_id,organization_id) UNIQUE
#  index_divisions_on_organization_id                         (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (division_status_id => division_statuses.id)
#  fk_rails_...  (organization_id => organizations.id) ON DELETE => nullify
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
            uniqueness: { scope: :organization_id,
                          message: :already_tagged, }
end
