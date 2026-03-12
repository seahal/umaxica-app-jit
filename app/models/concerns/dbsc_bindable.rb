# typed: false
# frozen_string_literal: true

module DbscBindable
  extend ActiveSupport::Concern

  def binding_method_nothing?
    binding_method_value == 0
  end

  def binding_method_dbsc?
    binding_method_value == 1
  end

  def binding_method_legacy?
    binding_method_value == 2
  end

  def dbsc_status_nothing?
    dbsc_status_value == 0
  end

  def dbsc_status_pending?
    dbsc_status_value == 1
  end

  def dbsc_status_active?
    dbsc_status_value == 2
  end

  def dbsc_status_failed?
    dbsc_status_value == 3
  end

  def dbsc_status_revoke?
    dbsc_status_value == 4
  end

  def dbsc_enabled?
    binding_method_dbsc?
  end

  private

  def binding_method_value
    self[dbsc_binding_method_attribute]
  end

  def dbsc_status_value
    self[dbsc_status_attribute]
  end

  def dbsc_binding_method_attribute
    return :binding_method_id if has_attribute?(:binding_method_id)
    return :user_token_binding_method_id if has_attribute?(:user_token_binding_method_id)
    return :staff_token_binding_method_id if has_attribute?(:staff_token_binding_method_id)

    raise NoMethodError, "No DBSC binding method attribute for #{self.class.name}"
  end

  def dbsc_status_attribute
    return :dbsc_status_id if has_attribute?(:dbsc_status_id)
    return :user_token_dbsc_status_id if has_attribute?(:user_token_dbsc_status_id)
    return :staff_token_dbsc_status_id if has_attribute?(:staff_token_dbsc_status_id)

    raise NoMethodError, "No DBSC status attribute for #{self.class.name}"
  end
end
