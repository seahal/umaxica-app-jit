# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_versions
# Database name: news
#
#  id              :bigint           not null, primary key
#  body            :text
#  description     :string
#  edited_by_type  :string
#  expires_at      :datetime         not null
#  permalink       :string(200)      not null
#  published_at    :datetime         not null
#  redirect_url    :string
#  response_mode   :string           not null
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  com_timeline_id :bigint           not null
#  edited_by_id    :bigint
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_com_timeline_versions_on_com_timeline_id_and_created_at  (com_timeline_id,created_at)
#  index_com_timeline_versions_on_edited_by_id                    (edited_by_id)
#  index_com_timeline_versions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (com_timeline_id => com_timelines.id) ON DELETE => cascade
#

class ComTimelineVersion < NewsRecord
  include Version
  include ::PublicId

  belongs_to :com_timeline, inverse_of: :com_timeline_versions
  has_one :latest_timeline,
          class_name: "ComTimeline",
          foreign_key: :latest_version_id,
          dependent: :nullify,
          inverse_of: :latest_version_record
  validates :permalink, presence: true, length: { maximum: 200 }
  validates :response_mode, presence: true
  validates :published_at, presence: true
  validates :expires_at, presence: true
end
