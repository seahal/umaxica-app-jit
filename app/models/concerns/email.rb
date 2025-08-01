module Email
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :pass_code

  included do
    before_save { self.address&.downcase! }

    encrypts :address, downcase: true, deterministic: true

    validates :address, format: { with: URI::MailTo::EMAIL_REGEXP },
                        presence: true,
                        uniqueness: { case_sensitive: false },
                        unless: Proc.new { |a| a.address.nil? && !a.pass_code.nil? }
    validates :confirm_policy, acceptance: true,
                               unless: Proc.new { |a| a.address.nil? && !a.pass_code.nil? }
    validates :pass_code, numericality: { only_integer: true },
                          length: { is: 6 },
                          presence: true,
                          unless: Proc.new { |a| a.pass_code.nil? && !a.address.nil? }
  end
end
