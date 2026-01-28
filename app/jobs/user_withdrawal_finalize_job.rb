# frozen_string_literal: true

class UserWithdrawalFinalizeJob < ApplicationJob
  queue_as :default

  def perform
    User.finalize_scheduled_withdrawals!
  end
end
