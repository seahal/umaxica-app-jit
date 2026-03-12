# typed: false
# frozen_string_literal: true

require "jwt"

module Dbsc
  module RecordAdapter
    module_function

    def binding_method_attribute(record)
      return :binding_method_id if record.has_attribute?(:binding_method_id)
      return :user_token_binding_method_id if record.has_attribute?(:user_token_binding_method_id)
      return :staff_token_binding_method_id if record.has_attribute?(:staff_token_binding_method_id)

      raise ArgumentError, "Unsupported DBSC binding method attribute for #{record.class.name}"
    end

    def dbsc_status_attribute(record)
      return :dbsc_status_id if record.has_attribute?(:dbsc_status_id)
      return :user_token_dbsc_status_id if record.has_attribute?(:user_token_dbsc_status_id)
      return :staff_token_dbsc_status_id if record.has_attribute?(:staff_token_dbsc_status_id)

      raise ArgumentError, "Unsupported DBSC status attribute for #{record.class.name}"
    end

    def binding_method_class(record)
      return AppPreferenceBindingMethod if record.is_a?(AppPreference)
      return OrgPreferenceBindingMethod if record.is_a?(OrgPreference)
      return ComPreferenceBindingMethod if record.is_a?(ComPreference)
      return UserTokenBindingMethod if record.is_a?(UserToken)
      return StaffTokenBindingMethod if record.is_a?(StaffToken)

      raise ArgumentError, "Unsupported DBSC binding method class for #{record.class.name}"
    end

    def dbsc_status_class(record)
      return AppPreferenceDbscStatus if record.is_a?(AppPreference)
      return OrgPreferenceDbscStatus if record.is_a?(OrgPreference)
      return ComPreferenceDbscStatus if record.is_a?(ComPreference)
      return UserTokenDbscStatus if record.is_a?(UserToken)
      return StaffTokenDbscStatus if record.is_a?(StaffToken)

      raise ArgumentError, "Unsupported DBSC status class for #{record.class.name}"
    end

    def dbsc_public_key(record)
      raw_key = normalize_public_key(record.dbsc_public_key)
      return nil if raw_key.blank?

      jwk = JWT::JWK.import(raw_key)
      return jwk.public_key if jwk.respond_to?(:public_key)
      return jwk.verify_key if jwk.respond_to?(:verify_key)

      nil
    end

    def normalize_public_key(public_key)
      return if public_key.blank?

      parsed =
        case public_key
        when String
          JSON.parse(public_key)
        when Hash
          public_key
        else
          public_key.respond_to?(:to_h) ? public_key.to_h : nil
        end

      parsed&.deep_stringify_keys
    end
  end
end
