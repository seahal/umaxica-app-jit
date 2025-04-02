class Telephone < ApplicationRecord
  attr_accessor :confirm_policy, :confirm_fido2
  validates :confirm_policy, acceptance: true
  validates :confirm_fido2, acceptance: true
end
