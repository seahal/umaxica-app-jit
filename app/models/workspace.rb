# typed: false
# == Schema Information
#
# Table name: workspaces
# Database name: operator
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

# Workspace uses the dedicated workspaces table.
class Workspace < OperatorRecord
  has_many :departments, dependent: :nullify, inverse_of: :workspace
  has_many :user_memberships, dependent: :restrict_with_error, inverse_of: :workspace

  validates :name, presence: true
end
