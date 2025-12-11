# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id          :uuid             not null, primary key
#  name        :string
#  domain      :string
#  parent_organization :uuid
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Organization < IdentityRecord
  has_many :user_organizations, dependent: :destroy
  has_many :users, through: :user_organizations
  has_many :roles, dependent: :destroy
  has_many :role_assignments, through: :roles

  validates :name, presence: true
end
