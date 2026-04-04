# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_topics
# Database name: guest
#
#  id             :bigint           not null, primary key
#  description    :text
#  title          :string(80)       default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  org_contact_id :bigint           not null
#  public_id      :string(21)       not null
#
# Indexes
#
#  index_org_contact_topics_on_org_contact_id  (org_contact_id)
#  index_org_contact_topics_on_public_id       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (org_contact_id => org_contacts.id)
#

class OrgContactTopic < GuestRecord
  include ::PublicId

  alias_attribute :body, :description

  belongs_to :org_contact, inverse_of: :org_contact_topics

  validates :title, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 8000 }, allow_blank: true
end
