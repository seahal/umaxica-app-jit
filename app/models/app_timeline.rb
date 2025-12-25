# == Schema Information
#
# Table name: app_timelines
#
#  id                     :uuid             not null, primary key
#  parent_id              :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  prev_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  succ_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  title                  :string           default(""), not null
#  description            :string           default(""), not null
#  app_timeline_status_id :string(255)      default("NONE"), not null
#  staff_id               :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  public_id              :string(21)       default(""), not null
#
# Indexes
#
#  index_app_timelines_on_app_timeline_status_id  (app_timeline_status_id)
#  index_app_timelines_on_parent_id               (parent_id)
#  index_app_timelines_on_prev_id                 (prev_id)
#  index_app_timelines_on_public_id               (public_id)
#  index_app_timelines_on_staff_id                (staff_id)
#  index_app_timelines_on_succ_id                 (succ_id)
#

class AppTimeline < BusinessesRecord
  include ::PublicId

  belongs_to :app_timeline_status, optional: true

  validates :app_timeline_status_id, length: { maximum: 255 }

  include Timeline

  has_many :app_timeline_audits,
           class_name: "AppTimelineAudit",
           foreign_key: :subject_id,
           primary_key: "id",
           inverse_of: :app_timeline,
           dependent: :restrict_with_error
end
