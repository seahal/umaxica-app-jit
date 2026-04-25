# typed: false
# frozen_string_literal: true

module Contact
  class ActorContext
    VERIFIED_USER_EMAIL_STATUSES = [
      UserEmailStatus::VERIFIED,
      UserEmailStatus::VERIFIED_WITH_SIGN_UP,
    ].freeze
    VERIFIED_USER_TELEPHONE_STATUSES = [
      UserTelephoneStatus::VERIFIED,
      UserTelephoneStatus::VERIFIED_WITH_SIGN_UP,
    ].freeze
    VERIFIED_STAFF_EMAIL_STATUSES = [StaffEmailStatus::VERIFIED].freeze
    VERIFIED_STAFF_TELEPHONE_STATUSES = [StaffTelephoneStatus::VERIFIED].freeze
    VERIFIED_CUSTOMER_EMAIL_STATUSES = [
      CustomerEmailStatus::VERIFIED,
      CustomerEmailStatus::VERIFIED_WITH_SIGN_UP,
    ].freeze
    VERIFIED_CUSTOMER_TELEPHONE_STATUSES = [
      CustomerTelephoneStatus::VERIFIED,
      CustomerTelephoneStatus::VERIFIED_WITH_SIGN_UP,
    ].freeze

    def initialize(actor:)
      @actor = actor
    end

    attr_reader :actor

    def email_address
      email_record&.address
    end

    def telephone_number
      telephone_record&.number
    end

    def ready?
      email_address.present? && telephone_number.present?
    end

    def actor_id
      actor&.id
    end

    def actor_type
      return "unknown" if actor.blank?
      return "customer" if actor&.respond_to?(:customer?) && actor.customer?
      return "staff" if actor&.respond_to?(:staff?) && actor.staff?
      return "user" if actor&.respond_to?(:user?) && actor.user?

      actor.class.name.demodulize.underscore
    end

    private

    def email_record
      @email_record ||= canonical_record(
        contact_records(:emails),
        email_status_attribute,
        verified_email_status_ids,
        :address,
      )
    end

    def telephone_record
      @telephone_record ||= canonical_record(
        contact_records(:telephones),
        telephone_status_attribute,
        verified_telephone_status_ids,
        :number,
      )
    end

    def contact_records(kind)
      return [] if actor.blank?

      case kind
      when :emails
        return actor.user_emails.to_a if actor.respond_to?(:user_emails)
        return actor.staff_emails.to_a if actor.respond_to?(:staff_emails)
        return actor.customer_emails.to_a if actor.respond_to?(:customer_emails)
      when :telephones
        return actor.user_telephones.to_a if actor.respond_to?(:user_telephones)
        return actor.staff_telephones.to_a if actor.respond_to?(:staff_telephones)
        return actor.customer_telephones.to_a if actor.respond_to?(:customer_telephones)
      end

      []
    end

    def email_status_attribute
      case
      when actor.respond_to?(:user_emails)
        :user_email_status_id
      when actor.respond_to?(:staff_emails)
        :staff_identity_email_status_id
      when actor.respond_to?(:customer_emails)
        :customer_email_status_id
      end
    end

    def telephone_status_attribute
      case
      when actor.respond_to?(:user_telephones)
        :user_identity_telephone_status_id
      when actor.respond_to?(:staff_telephones)
        :staff_identity_telephone_status_id
      when actor.respond_to?(:customer_telephones)
        :customer_telephone_status_id
      end
    end

    def verified_email_status_ids
      case
      when actor.respond_to?(:user_emails)
        VERIFIED_USER_EMAIL_STATUSES
      when actor.respond_to?(:staff_emails)
        VERIFIED_STAFF_EMAIL_STATUSES
      when actor.respond_to?(:customer_emails)
        VERIFIED_CUSTOMER_EMAIL_STATUSES
      else
        []
      end
    end

    def verified_telephone_status_ids
      case
      when actor.respond_to?(:user_telephones)
        VERIFIED_USER_TELEPHONE_STATUSES
      when actor.respond_to?(:staff_telephones)
        VERIFIED_STAFF_TELEPHONE_STATUSES
      when actor.respond_to?(:customer_telephones)
        VERIFIED_CUSTOMER_TELEPHONE_STATUSES
      else
        []
      end
    end

    def canonical_record(records, status_attribute, verified_status_ids, value_attribute)
      verified =
        records.find do |record|
          verified_status_ids.include?(record.public_send(status_attribute)) &&
            record.public_send(value_attribute).present?
        end
      return verified if verified

      records.find { |record| record.public_send(value_attribute).present? }
    end
  end
end
