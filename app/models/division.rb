# frozen_string_literal: true

# == Schema Information
#
# Table name: divisions
# Database name: operator
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
