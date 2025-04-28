# frozen_string_literal: true

# == Schema Information
#
# Table name: staffs
#
#  id         :binary           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Staff < AccountsRecord
  has_many :emails, foreign_key: "address"
end
