# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_topics
#
#  id                :uuid             not null, primary key
#  activated         :boolean          default(FALSE), not null
#  app_contact_id    :uuid             not null
#  created_at        :datetime         not null
#  deletable         :boolean          default(FALSE), not null
#  expires_at        :timestamptz      not null
#  otp_attempts_left :integer          default(3), not null
#  otp_digest        :string(255)      default(""), not null
#  otp_expires_at    :timestamptz      default("-infinity"), not null
#  public_id         :string(21)       default(""), not null
#  remaining_views   :integer          default(10), not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_app_contact_topics_on_app_contact_id  (app_contact_id)
#  index_app_contact_topics_on_expires_at      (expires_at)
#  index_app_contact_topics_on_public_id       (public_id)
#

class AppContactTopic < GuestsRecord
  include ::PublicId

  belongs_to :app_contact

  validates :otp_digest, length: { maximum: 255 }
end
