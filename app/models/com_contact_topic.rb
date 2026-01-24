# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_topics
# Database name: guest
#
#  id                :uuid             not null, primary key
#  activated         :boolean          default(FALSE), not null
#  deletable         :boolean          default(FALSE), not null
#  description       :text             default(""), not null
#  expires_at        :timestamptz      not null
#  otp_attempts_left :integer          default(0), not null
#  otp_digest        :string(255)      default(""), not null
#  otp_expires_at    :timestamptz      default(-Infinity), not null
#  remaining_views   :integer          default(0), not null
#  title             :string           default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  com_contact_id    :uuid             not null
#  public_id         :string(21)       default(""), not null
#
# Indexes
#
#  index_com_contact_topics_on_com_contact_id  (com_contact_id)
#  index_com_contact_topics_on_expires_at      (expires_at)
#  index_com_contact_topics_on_public_id       (public_id)
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#

class ComContactTopic < GuestRecord
  include ::PublicId

  belongs_to :com_contact, inverse_of: :com_contact_topics

  validates :otp_digest, length: { maximum: 255 }
end
