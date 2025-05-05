module Telephone
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :confirm_using_mfa, :pass_code

  included do
    before_save { self.number&.downcase! }

    encrypts :number, downcase: true, deterministic: true

    validates :number, length: 3..255,
              format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
    validates :confirm_policy, acceptance: true,
              unless: Proc.new { |a| a.number.nil? && !a.pass_code.nil? }
    validates :confirm_using_mfa, acceptance: true,
              unless: Proc.new { |a| a.number.nil? && !a.pass_code.nil? }
    validates :pass_code, numericality: { only_integer: true },
              length: { is: 6 },
              presence: true,
              unless: Proc.new { |a| a.pass_code.nil? && !a.number.nil?  }
  end
end
