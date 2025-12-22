class OrgContactTopic < GuestsRecord
  include ::PublicId

  belongs_to :org_contact

  # Allow assignment of optional metadata fields used in notifications without persisting them.
  attr_accessor :title, :description
end
