module RecoverCode
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :confirm_using_mfa, :pass_code

  included do
  end
end
