# == Schema Information
#
# Table name: timelines
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  entity_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
class Timeline < BusinessesRecord
end
