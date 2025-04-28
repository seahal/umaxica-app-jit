# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id         :binary           default(""), not null
#  address    :string(512)      not null, primary key
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserEmail < Email
  attr_accessor :confirm_policy
  validates :confirm_policy, acceptance: true
end
