# frozen_string_literal: true

module UserSecret::Kinds
  extend ActiveSupport::Concern

  # Kind constants
  LOGIN = "LOGIN"
  TOTP = "TOTP"
  RECOVERY = "RECOVERY"
  API = "API"

  ALL = [LOGIN, TOTP, RECOVERY, API].freeze

  # Predicates using string equality on user_secret_kind_id column (no JOINs)
  def login_secret?
    user_secret_kind_id == LOGIN
  end

  def totp_secret?
    user_secret_kind_id == TOTP
  end

  def recovery_secret?
    user_secret_kind_id == RECOVERY
  end

  def api_secret?
    user_secret_kind_id == API
  end
end
