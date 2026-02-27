# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_topics
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
#  title             :string(80)       default(""), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  app_contact_id    :bigint           not null
#  public_id         :string(21)       not null
#
# Indexes
#
#  index_app_contact_topics_on_app_contact_id  (app_contact_id)
#  index_app_contact_topics_on_expires_at      (expires_at)
#  index_app_contact_topics_on_public_id       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_contact_id => app_contacts.id)
#

class AppContactTopic < GuestRecord
  include ::PublicId

  alias_attribute :body, :description

  belongs_to :app_contact, inverse_of: :app_contact_topics

  validates :title, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 8000 }, allow_blank: true
  validates :otp_digest, length: { maximum: 255 }
end
