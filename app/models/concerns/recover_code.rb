# frozen_string_literal: true

module RecoverCode
  extend ActiveSupport::Concern

  attr_accessor :confirm_policy, :confirm_using_mfa, :pass_code

  included do
    # Add validations, callbacks, or associations here when the RecoverCode
    # feature is implemented (e.g., validates :pass_code format, before_save hooks).
  end
end
