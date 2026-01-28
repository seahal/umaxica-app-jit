# frozen_string_literal: true

module StaffSecret::Kinds
  extend ActiveSupport::Concern

  # Lifetime-based kind constants (UPPER_SNAKE_CASE)
  UNLIMITED = "UNLIMITED"
  ONE_TIME = "ONE_TIME"
  TIME_BOUND = "TIME_BOUND"

  ALL = [ UNLIMITED, ONE_TIME, TIME_BOUND ].freeze

  # Predicates using string equality on staff_secret_kind_id column (no JOINs)
  def unlimited?
    staff_secret_kind_id == UNLIMITED
  end

  def one_time?
    staff_secret_kind_id == ONE_TIME
  end

  def time_bound?
    staff_secret_kind_id == TIME_BOUND
  end
end
