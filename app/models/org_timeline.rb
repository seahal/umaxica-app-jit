# == Schema Information
#
# Table name: org_timelines
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  org_timeline_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
class OrgTimeline < BusinessesRecord
  belongs_to :org_timeline_status, optional: true

  include Timeline
end
