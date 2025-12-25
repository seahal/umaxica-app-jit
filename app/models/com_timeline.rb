# == Schema Information
#
# Table name: com_timelines
#
#  id                     :uuid             not null, primary key
#  parent_id              :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  prev_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  succ_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  title                  :string           default(""), not null
#  description            :string           default(""), not null
#  com_timeline_status_id :string(255)      default("NONE"), not null
#  staff_id               :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  public_id              :string(21)       default(""), not null
#
# Indexes
#
#  index_com_timelines_on_com_timeline_status_id  (com_timeline_status_id)
#  index_com_timelines_on_parent_id               (parent_id)
#  index_com_timelines_on_prev_id                 (prev_id)
#  index_com_timelines_on_public_id               (public_id)
#  index_com_timelines_on_staff_id                (staff_id)
#  index_com_timelines_on_succ_id                 (succ_id)
#

class ComTimeline < BusinessesRecord
  include ::PublicId

  belongs_to :com_timeline_status, optional: true

  validates :com_timeline_status_id, length: { maximum: 255 }

  include Timeline

  has_many :com_timeline_audits,
           class_name: "ComTimelineAudit",
           foreign_key: :subject_id,
           primary_key: "id",
           inverse_of: :com_timeline,
           dependent: :restrict_with_error
end
