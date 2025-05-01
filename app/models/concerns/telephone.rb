module Telephone
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :confirm_fido2

  included do
    validates :number, length: 3..255,
              format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
    validates :confirm_policy, acceptance: true
    validates :confirm_fido2, acceptance: true
  end
end
