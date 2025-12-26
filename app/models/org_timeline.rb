# == Schema Information
#
# Table name: org_timelines
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
#
# Indexes
#
#  index_org_timelines_on_permalink                    (permalink) UNIQUE
#  index_org_timelines_on_published_at_and_expires_at  (published_at,expires_at)
#

class OrgTimeline < TimelineBase
  has_many :org_timeline_versions, dependent: :delete_all
  has_many :org_timeline_audits,
           -> { where(subject_type: "OrgTimeline") },
           class_name: "OrgTimelineAudit",
           foreign_key: :subject_id,
           inverse_of: :org_timeline

  def latest_version
    org_timeline_versions.order(created_at: :desc).first!
  end
end
