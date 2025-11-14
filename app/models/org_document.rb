# == Schema Information
#
# Table name: documents
#
#  id               :uuid             not null, primary key
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
class OrgDocument < BusinessesRecord
  encrypts :title
  encrypts :description
end
