# == Schema Information
#
# Table name: staff_telephones
#
#  id         :bigint           not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class StaffTelephone < AccountsRecord

end
