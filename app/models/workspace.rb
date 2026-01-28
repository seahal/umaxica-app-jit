# == Schema Information
#
# Table name: organizations
# Database name: operator
#
#  id                  :uuid             not null, primary key
#  domain              :string           default(""), not null
#  name                :string           default(""), not null
#  parent_organization :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  admin_id            :uuid
#  department_id       :uuid
#  parent_id           :uuid
#  workspace_status_id :string(255)
#
# Indexes
#
#  index_organizations_on_admin_id             (admin_id)
#  index_organizations_on_department_id        (department_id)
#  index_organizations_on_domain               (domain) UNIQUE
#  index_organizations_on_parent_id            (parent_id)
#  index_organizations_on_workspace_status_id  (workspace_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_status_id => workspace_statuses.id) ON DELETE => restrict
#

# frozen_string_literal: true

# Workspace mirrors Organization for historical compatibility.
class Workspace < Organization
  self.table_name = Organization.table_name
end
