# frozen_string_literal: true

module UserSecret::Kinds
  extend ActiveSupport::Concern

  # Lifetime-based kind constants (UPPER_SNAKE_CASE)
  UNLIMITED = "UNLIMITED"
  ONE_TIME = "ONE_TIME"
  TIME_BOUND = "TIME_BOUND"

  ALL = [ UNLIMITED, ONE_TIME, TIME_BOUND ].freeze

  # Predicates using string equality on user_secret_kind_id column (no JOINs)
  def unlimited?
    user_secret_kind_id == UNLIMITED
  end

  def one_time?
    user_secret_kind_id == ONE_TIME
  end

  def time_bound?
    user_secret_kind_id == TIME_BOUND
  end
end
