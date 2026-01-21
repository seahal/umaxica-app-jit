# frozen_string_literal: true

module StaffSecret::Kinds
  extend ActiveSupport::Concern

  # Kind constants
  LOGIN = "LOGIN"
  TOTP = "TOTP"

  ALL = [LOGIN, TOTP].freeze

  # Predicates using string equality on staff_secret_kind_id column (no JOINs)
  def login_secret?
    staff_secret_kind_id == LOGIN
  end

  def totp_secret?
    staff_secret_kind_id == TOTP
  end
end
