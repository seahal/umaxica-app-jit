# typed: false
# frozen_string_literal: true

module Preference
  module Adoption
    extend ActiveSupport::Concern

    CHILD_RECORD_TYPES = %i(language timezone region colortheme).freeze
    COOKIE_CONSENT_FIELDS = %i(consented functional performant targetable).freeze

    private

    # Called after login to restore the user's/staff's last known preference settings.
    # Non-fatal: never blocks login on failure.
    def adopt_preference_for!(resource)
      return unless adoptable_preference_class?
      return if resource.blank? || @preferences.blank?

      source = find_last_linked_preference(resource)
      restore_preference_from!(source) if source.present?
      link_preference_to!(resource)
    rescue StandardError => e
      Rails.event.record("preference.adoption.error", error: e.class.name, message: e.message)
    end

    # Called during preference rotation to re-link the new preference to the resource.
    # Non-fatal: never blocks rotation on failure.
    def adopt_rotated_preference!(resource, new_preference)
      return unless adoptable_preference_class?
      return if resource.blank? || new_preference.blank?

      link_preference_record!(resource, new_preference)
    rescue StandardError => e
      Rails.event.record("preference.adoption.rotation_error", error: e.class.name, message: e.message)
    end

    def adoptable_preference_class?
      name = preference_class.name
      name == "AppPreference" || name == "OrgPreference"
    end

    # Find the most recently linked preference for this resource via the join table.
    def find_last_linked_preference(resource)
      join_class, resource_fk, preference_fk = adoption_mapping
      return nil unless join_class

      join_record = join_class
        .where(resource_fk => resource.id)
        .order(created_at: :desc)
        .first
      return nil unless join_record

      join_record.public_send(preference_fk.to_s.delete_suffix("_id"))
    end

    # Copy child record option_ids and cookie consent from source to @preferences.
    def restore_preference_from!(source)
      association_prefix = preference_class.name.underscore

      CHILD_RECORD_TYPES.each do |type|
        source_child = source.public_send("#{association_prefix}_#{type}")
        next unless source_child&.option_id

        target_child = @preferences.public_send("#{association_prefix}_#{type}")
        next unless target_child

        if target_child.option_id != source_child.option_id
          PreferenceRecord.connected_to(role: :writing) do
            target_child.update!(option_id: source_child.option_id)
          end
        end
      end

      restore_cookie_consent!(source, association_prefix)
      issue_access_token_from(@preferences)
    end

    def restore_cookie_consent!(source, association_prefix)
      source_cookie = source.public_send("#{association_prefix}_cookie")
      return unless source_cookie&.consented

      target_cookie = @preferences.public_send("#{association_prefix}_cookie") ||
        @preferences.public_send("create_#{association_prefix}_cookie!")

      attrs =
        COOKIE_CONSENT_FIELDS.index_with do |field|
          source_cookie.public_send(field)
        end

      PreferenceRecord.connected_to(role: :writing) do
        target_cookie.update!(attrs)
      end
    end

    # Link @preferences to the resource via the join table.
    def link_preference_to!(resource)
      link_preference_record!(resource, @preferences)
    end

    def link_preference_record!(resource, preference)
      join_class, resource_fk, preference_fk = adoption_mapping
      return unless join_class

      PreferenceRecord.connected_to(role: :writing) do
        join_class.find_or_create_by!(
          resource_fk => resource.id,
          preference_fk => preference.id,
        )
      end
    end

    # Returns [JoinClass, resource_fk_symbol, preference_fk_symbol] based on preference_class.
    def adoption_mapping
      case preference_class.name
      when "AppPreference"
        [UserAppPreference, :user_id, :app_preference_id]
      when "OrgPreference"
        [StaffOrgPreference, :staff_id, :org_preference_id]
      else
        [nil, nil, nil]
      end
    end
  end
end
