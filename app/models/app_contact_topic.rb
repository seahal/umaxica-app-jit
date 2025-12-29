# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_topics
#
#  id                :uuid             not null, primary key
#  app_contact_id    :uuid             not null
#  activated         :boolean          default(FALSE), not null
#  deletable         :boolean          default(FALSE), not null
#  remaining_views   :integer          default(0), not null
#  otp_digest        :string(255)      default(""), not null
#  otp_expires_at    :timestamptz      default("-infinity"), not null
#  otp_attempts_left :integer          default(0), not null
#  expires_at        :timestamptz      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  public_id         :string(21)       default(""), not null
#
# Indexes
#
#  index_app_contact_topics_on_app_contact_id  (app_contact_id)
#  index_app_contact_topics_on_expires_at      (expires_at)
#  index_app_contact_topics_on_public_id       (public_id)
#

class AppContactTopic < GuestsRecord
  include ::PublicId

  belongs_to :app_contact, inverse_of: :app_contact_topics

  validates :otp_digest, length: { maximum: 255 }
end
