# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timelines
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
#  index_app_timelines_on_permalink                    (permalink) UNIQUE
#  index_app_timelines_on_published_at_and_expires_at  (published_at,expires_at)
#  index_app_timelines_on_status_id                    (status_id)
#

class AppTimeline < NewsRecord
  include Timeline

  belongs_to :app_timeline_status,
             class_name: "AppTimelineStatus",
             foreign_key: :status_id,
             inverse_of: :app_timelines

  validates :status_id, length: { maximum: 255 }
  has_many :app_timeline_versions, dependent: :delete_all
  has_many :app_timeline_audits,
           -> { where(subject_type: "AppTimeline") },
           class_name: "AppTimelineAudit",
           foreign_key: :subject_id,
           inverse_of: :app_timeline,
           dependent: :delete_all
  has_many :app_timeline_tags, dependent: :delete_all, inverse_of: :app_timeline
  has_many :tag_masters,
           through: :app_timeline_tags,
           source: :app_timeline_tag_master
  has_one :category,
          class_name: "AppTimelineCategory",
          dependent: :delete,
          inverse_of: :app_timeline
  has_one :category_master,
          through: :category,
          source: :app_timeline_category_master

  def latest_version
    app_timeline_versions.order(created_at: :desc).first!
  end
end
