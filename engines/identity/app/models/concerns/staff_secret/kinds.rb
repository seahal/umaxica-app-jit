# typed: false
# frozen_string_literal: true

module StaffSecret::Kinds
  extend ActiveSupport::Concern

  # Kind constants (integer IDs)
  LOGIN = StaffSecretKind::LOGIN
  TOTP = StaffSecretKind::TOTP
  PERMANENT = StaffSecretKind::PERMANENT
  ONE_TIME = StaffSecretKind::ONE_TIME

  ALL = [LOGIN, TOTP].freeze

  # Predicates using string equality on staff_secret_kind_id column (no JOINs)
  def login_secret?
    staff_secret_kind_id == LOGIN
  end

  def totp_secret?
    staff_secret_kind_id == TOTP
  end

  def recovery_secret?
    false
  end

  def permanent_secret?
    staff_secret_kind_id == PERMANENT
  end

  def one_time_secret?
    staff_secret_kind_id == ONE_TIME
  end
end
