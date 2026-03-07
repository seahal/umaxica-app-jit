# typed: false
# == Schema Information
#
# Table name: organizations
# Database name: operator
#
#  id                  :bigint           not null, primary key
#  domain              :string           default(""), not null
#  name                :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  department_id       :bigint
#  operator_id         :bigint
#  parent_id           :bigint
#  workspace_status_id :bigint           default(0), not null
#
# Indexes
#
#  index_organizations_on_department_id        (department_id)
#  index_organizations_on_domain               (domain) UNIQUE
#  index_organizations_on_operator_id          (operator_id)
#  index_organizations_on_parent_id            (parent_id)
#  index_organizations_on_workspace_status_id  (workspace_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_status_id => organization_statuses.id)
#

# frozen_string_literal: true

# Workspace mirrors Organization for historical compatibility.
class Workspace < Organization
  self.table_name = Organization.table_name # TODO: find out why this code was implemented.
end
