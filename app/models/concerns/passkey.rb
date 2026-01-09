# frozen_string_literal: true

module Passkey
  extend ActiveSupport::Concern

  def passkey_enabled?
    false
  end

  def can_register_passkey?
    respond_to?(:user_passkeys) || respond_to?(:staff_passkeys)
  end
end
