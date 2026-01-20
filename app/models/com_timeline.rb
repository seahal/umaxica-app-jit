# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timelines
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  expires_at    :datetime         default("infinity"), not null
#  position      :integer          default(0), not null
#  published_at  :datetime         default("infinity"), not null
#  redirect_url  :string
#  response_mode :string           default("html"), not null
#  slug_id       :string(32)       default(""), not null
#  status_id     :string(255)      default("NEYO"), not null
#  updated_at    :datetime         not null
#  lock_version  :integer          default(0), not null
#
# Indexes
#
#  index_com_timelines_on_published_at_and_expires_at  (published_at,expires_at)
#  index_com_timelines_on_slug_id                      (slug_id)
#  index_com_timelines_on_status_id                    (status_id)
#

class ComTimeline < NewsRecord
  include ::SlugId
  include Timeline

  belongs_to :com_timeline_status,
             class_name: "ComTimelineStatus",
             foreign_key: :status_id,
             inverse_of: :com_timelines

  belongs_to :latest_version_record,
             class_name: "ComTimelineVersion",
             foreign_key: :latest_version_id,
             inverse_of: :latest_timeline,
             optional: true
  belongs_to :latest_revision_record,
             class_name: "ComTimelineRevision",
             foreign_key: :latest_revision_id,
             inverse_of: :latest_timeline,
             optional: true

  has_many :com_timeline_versions, dependent: :delete_all, inverse_of: :com_timeline
  has_many :com_timeline_revisions, dependent: :delete_all, inverse_of: :com_timeline
  has_many :com_timeline_audits,
           -> { where(subject_type: "ComTimeline") },
           class_name: "ComTimelineAudit",
           foreign_key: :subject_id,
           inverse_of: :com_timeline,
           dependent: :delete_all
  has_many :com_timeline_tags, dependent: :delete_all, inverse_of: :com_timeline
  has_many :tag_masters,
           through: :com_timeline_tags,
           source: :com_timeline_tag_master
  has_one :category,
          class_name: "ComTimelineCategory",
          dependent: :delete,
          inverse_of: :com_timeline
  has_one :category_master,
          through: :category,
          source: :com_timeline_category_master
  validates :status_id, length: { maximum: 255 }

  def latest_version
    com_timeline_versions.order(created_at: :desc).first!
  end
end
