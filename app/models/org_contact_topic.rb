# frozen_string_literal: true

class OrgContactTopic < GuestsRecord
  include ::PublicId

  belongs_to :org_contact
end
