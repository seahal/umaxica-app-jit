# frozen_string_literal: true

class UserOrganization < IdentityRecord
  belongs_to :user, class_name: "User", inverse_of: :user_organizations
  belongs_to :organization, class_name: "Workspace", inverse_of: :user_organizations
end
