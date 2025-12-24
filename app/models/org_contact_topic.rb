# == Schema Information
#
# Table name: org_contact_topics
#
#  id                :uuid             not null, primary key
#  activated         :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  deletable         :boolean          default(FALSE), not null
#  expires_at        :timestamptz      not null
#  org_contact_id    :uuid             not null
#  otp_attempts_left :integer          default(3), not null
#  otp_digest        :string(255)      default(""), not null
#  otp_expires_at    :timestamptz      default("-infinity"), not null
#  public_id         :string(21)       default(""), not null
#  remaining_views   :integer          default(10), not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_org_contact_topics_on_expires_at      (expires_at)
#  index_org_contact_topics_on_org_contact_id  (org_contact_id)
#  index_org_contact_topics_on_public_id       (public_id)
#

class OrgContactTopic < GuestsRecord
  include ::PublicId

  belongs_to :org_contact

  # Allow assignment of optional metadata fields used in notifications without persisting them.
  attr_accessor :title, :description
end
