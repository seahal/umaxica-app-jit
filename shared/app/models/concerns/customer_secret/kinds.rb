# typed: false
# frozen_string_literal: true

module CustomerSecret::Kinds
  extend ActiveSupport::Concern

  LOGIN = CustomerSecretKind::LOGIN
  TOTP = CustomerSecretKind::TOTP
  RECOVERY = CustomerSecretKind::RECOVERY
  API = CustomerSecretKind::API
  PERMANENT = CustomerSecretKind::PERMANENT
  ONE_TIME = CustomerSecretKind::ONE_TIME

  ALL = [LOGIN, TOTP, RECOVERY, API].freeze

  def login_secret?
    customer_secret_kind_id == LOGIN
  end

  def totp_secret?
    customer_secret_kind_id == TOTP
  end

  def recovery_secret?
    customer_secret_kind_id == RECOVERY
  end

  def api_secret?
    customer_secret_kind_id == API
  end

  def permanent_secret?
    customer_secret_kind_id == PERMANENT
  end

  def one_time_secret?
    customer_secret_kind_id == ONE_TIME
  end
end
