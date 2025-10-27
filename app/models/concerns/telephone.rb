module Telephone
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :confirm_using_mfa, :pass_code

  included do
    encrypts :number, deterministic: true

    validates :number, length: { in: 3..20 },
              format: { with: /\A\+?[\d\s\-\(\)]+\z/ },
              uniqueness: { case_sensitive: false }
    validates :confirm_policy, acceptance: true,
              unless: Proc.new { |a| a.number.nil? && !a.pass_code.nil? }
    validates :confirm_using_mfa, acceptance: true,
              unless: Proc.new { |a| a.number.nil? && !a.pass_code.nil? }
    validates :pass_code, numericality: { only_integer: true },
              length: { is: 6 },
              presence: true,
              unless: Proc.new { |a| a.pass_code.nil? && !a.number.nil? }
  end
end
