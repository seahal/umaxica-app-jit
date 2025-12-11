class UserOrganization < IdentityRecord
  belongs_to :user, class_name: "User", inverse_of: :user_organizations
  belongs_to :organization, inverse_of: :user_organizations
end
