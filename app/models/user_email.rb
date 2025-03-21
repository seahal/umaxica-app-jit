# frozen_string_literal: true

class UserEmail < Email
  attr_accessor :confirm_policy
  validates :confirm_policy, acceptance: true
end
