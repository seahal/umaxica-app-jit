# == Schema Information
#
# Table name: com_timelines
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  com_timeline_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
class ComTimeline < BusinessesRecord
  belongs_to :com_timeline_status, optional: true

  include Timeline
end
