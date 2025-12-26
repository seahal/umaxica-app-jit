# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timelines
#
#  id            :uuid             not null, primary key
#  permalink     :string(200)      not null
#  response_mode :string           default("html"), not null
#  redirect_url  :string
#  revision_key  :string           not null
#  published_at  :datetime         default("infinity"), not null
#  expires_at    :datetime         default("infinity"), not null
#  position      :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status_id     :string(255)      default("NONE"), not null
#
# Indexes
#
#  index_com_timelines_on_permalink                    (permalink) UNIQUE
#  index_com_timelines_on_published_at_and_expires_at  (published_at,expires_at)
#  index_com_timelines_on_status_id                    (status_id)
#

class ComTimeline < TimelineRecord
  include Timeline

  belongs_to :com_timeline_status,
             class_name: "ComTimelineStatus",
             foreign_key: :status_id,
             inverse_of: :com_timelines
  has_many :com_timeline_versions, dependent: :delete_all
  has_many :com_timeline_audits,
           -> { where(subject_type: "ComTimeline") },
           class_name: "ComTimelineAudit",
           foreign_key: :subject_id,
           inverse_of: :com_timeline,
           dependent: :delete_all

  def latest_version
    com_timeline_versions.order(created_at: :desc).first!
  end
end
