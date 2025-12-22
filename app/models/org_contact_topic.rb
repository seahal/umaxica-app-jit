class OrgContactTopic < GuestsRecord
  include ::PublicId

  belongs_to :org_contact
end
