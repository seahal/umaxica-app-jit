# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id              :uuid             not null, primary key
#  name            :string
#  key             :string
#  description     :text
#  organization_id :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Role < IdentityRecord
  belongs_to :organization, inverse_of: :roles
  has_many :role_assignments, dependent: :destroy, inverse_of: :role
  has_many :users, through: :role_assignments, source: :user
  has_many :staffs, through: :role_assignments, source: :staff
end
