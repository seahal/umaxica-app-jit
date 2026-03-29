# typed: false
# frozen_string_literal: true

module DbscBindable
  extend ActiveSupport::Concern

  class_methods do
    def dbsc_binding_method_attribute_name
      return :binding_method_id if attribute_names.include?("binding_method_id")
      return :user_token_binding_method_id if attribute_names.include?("user_token_binding_method_id")
      return :staff_token_binding_method_id if attribute_names.include?("staff_token_binding_method_id")
      return :customer_token_binding_method_id if attribute_names.include?("customer_token_binding_method_id")

      raise NoMethodError, "No DBSC binding method attribute for #{name}"
    end

    def dbsc_status_attribute_name
      return :dbsc_status_id if attribute_names.include?("dbsc_status_id")
      return :user_token_dbsc_status_id if attribute_names.include?("user_token_dbsc_status_id")
      return :staff_token_dbsc_status_id if attribute_names.include?("staff_token_dbsc_status_id")
      return :customer_token_dbsc_status_id if attribute_names.include?("customer_token_dbsc_status_id")

      raise NoMethodError, "No DBSC status attribute for #{name}"
    end

    def dbsc_binding_method_class
      const_get(:DBSC_BINDING_METHOD_CLASS)
    rescue NameError
      raise NoMethodError, "No DBSC binding method class for #{name}"
    end

    def dbsc_status_class
      const_get(:DBSC_STATUS_CLASS)
    rescue NameError
      raise NoMethodError, "No DBSC status class for #{name}"
    end
  end

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
    self.class.dbsc_binding_method_attribute_name
  end

  def dbsc_status_attribute
    self.class.dbsc_status_attribute_name
  end
end
