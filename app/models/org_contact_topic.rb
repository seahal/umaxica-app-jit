# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_topics
# Database name: guest
#
#  id                :bigint           not null, primary key
#  activated         :boolean          default(FALSE), not null
#  deletable         :boolean          default(FALSE), not null
#  expires_at        :datetime         not null
#  otp_attempts_left :integer          default(3), not null
#  otp_digest        :string
#  otp_expires_at    :datetime
#  remaining_views   :integer          default(10), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  org_contact_id    :bigint           not null
#  public_id         :string(21)       not null
#
# Indexes
#
#  index_org_contact_topics_on_expires_at      (expires_at)
#  index_org_contact_topics_on_org_contact_id  (org_contact_id)
#  index_org_contact_topics_on_public_id       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (org_contact_id => org_contacts.id)
#

class OrgContactTopic < GuestRecord
  include ::PublicId

  # Allow assignment of optional metadata fields used in notifications without persisting them.
  attr_accessor :title, :description

  belongs_to :org_contact, inverse_of: :org_contact_topics

  validates :otp_digest, length: { maximum: 255 }
end
