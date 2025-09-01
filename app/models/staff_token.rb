# == Schema Information
#
# Table name: staff_tokens
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :uuid
#
class StaffToken < TokensRecord
end
