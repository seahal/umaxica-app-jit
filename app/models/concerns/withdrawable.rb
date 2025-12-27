# frozen_string_literal: true

# Shared withdraw/recovery logic for accounts (User, Staff)
module Withdrawable
  extend ActiveSupport::Concern

  # Deterministic recovery window: use 30 days to avoid month-length ambiguity.
  WITHDRAWAL_RECOVERY_PERIOD = 30.days

  included do
    scope :withdrawn, -> { where("withdrawn_at < '+infinity'::timestamp") }
  end

  def withdrawn?
    withdrawn_at.present? && withdrawn_at < Float::INFINITY
  end

  def active?
    !withdrawn?
  end

  def recovery_deadline
    return nil unless withdrawn_at

    withdrawn_at + WITHDRAWAL_RECOVERY_PERIOD
  end

  def can_recover?
    withdrawn? && Time.current < recovery_deadline
  end

  def permanently_deletable?
    withdrawn? && Time.current >= recovery_deadline
  end
end
