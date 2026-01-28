# frozen_string_literal: true

module RecoverCode
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :confirm_using_mfa, :pass_code

  included do
    # TODO: Add included block implementation if needed
  end
end
