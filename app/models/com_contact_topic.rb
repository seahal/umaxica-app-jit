# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_topics
# Database name: guest
#
#  id                :bigint           not null, primary key
#  activated         :boolean          default(FALSE), not null
#  deletable         :boolean          default(FALSE), not null
#  description       :text
#  expires_at        :datetime         not null
#  otp_attempts_left :integer          default(3), not null
#  otp_digest        :string
#  otp_expires_at    :datetime
#  remaining_views   :integer          default(10), not null
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  com_contact_id    :bigint           not null
#  public_id         :string(21)       not null
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
