# == Schema Information
#
# Table name: timelines
#
#  id               :bigint           not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  entity_status_id :string
#  parent_id        :binary
#  prev_id          :binary
#  staff_id         :binary
#  succ_id          :binary
#
class Timeline < BusinessesRecord
end
