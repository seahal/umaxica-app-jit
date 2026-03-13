# typed: false
# frozen_string_literal: true

require "test_helper"

module Preference
  class AdoptionTest < ActiveSupport::TestCase
    fixtures :users, :user_statuses,
             :app_preferences, :app_preference_statuses,
             :app_preference_binding_methods, :app_preference_dbsc_statuses,
             :app_preference_language_options, :app_preference_timezone_options,
             :app_preference_region_options, :app_preference_colortheme_options,
             :user_app_preferences

    setup do
      @user = users(:none_user)
      @preference = app_preferences(:one)
      @new_preference = app_preferences(:two)
      @adoption = build_adoption_context(@preference)

      # Clean up any existing links for our test user
      PreferenceRecord.connected_to(role: :writing) do
        UserAppPreference.where(user_id: @user.id).delete_all
      end
    end

    # --- adoptable_preference_class? ---

    test "adoptable_preference_class? returns true for AppPreference" do
      assert @adoption.send(:adoptable_preference_class?)
    end

    test "adoptable_preference_class? returns false for ComPreference" do
      adoption = build_adoption_context(@preference, preference_class_name: "ComPreference")

      assert_not adoption.send(:adoptable_preference_class?)
    end

    # --- adoption_mapping ---

    test "adoption_mapping returns UserAppPreference for AppPreference" do
      join_class, resource_fk, preference_fk = @adoption.send(:adoption_mapping)

      assert_equal UserAppPreference, join_class
      assert_equal :user_id, resource_fk
      assert_equal :app_preference_id, preference_fk
    end

    test "adoption_mapping returns StaffOrgPreference for OrgPreference" do
      adoption = build_adoption_context(@preference, preference_class_name: "OrgPreference")
      join_class, resource_fk, preference_fk = adoption.send(:adoption_mapping)

      assert_equal StaffOrgPreference, join_class
      assert_equal :staff_id, resource_fk
      assert_equal :org_preference_id, preference_fk
    end

    test "adoption_mapping returns nils for ComPreference" do
      adoption = build_adoption_context(@preference, preference_class_name: "ComPreference")
      join_class, resource_fk, preference_fk = adoption.send(:adoption_mapping)

      assert_nil join_class
      assert_nil resource_fk
      assert_nil preference_fk
    end

    # --- link_preference_to! ---

    test "link_preference_to! creates UserAppPreference join record" do
      assert_difference "UserAppPreference.count", 1 do
        @adoption.send(:link_preference_to!, @user)
      end

      join = UserAppPreference.find_by(user_id: @user.id, app_preference_id: @preference.id)

      assert_not_nil join
    end

    test "link_preference_to! is idempotent" do
      @adoption.send(:link_preference_to!, @user)

      assert_no_difference "UserAppPreference.count" do
        @adoption.send(:link_preference_to!, @user)
      end
    end

    # --- find_last_linked_preference ---

    test "find_last_linked_preference returns nil when no link exists" do
      result = @adoption.send(:find_last_linked_preference, @user)

      assert_nil result
    end

    test "find_last_linked_preference returns the most recent linked preference" do
      PreferenceRecord.connected_to(role: :writing) do
        UserAppPreference.create!(user_id: @user.id, app_preference_id: @preference.id)
      end
      # Small sleep to ensure distinct created_at
      PreferenceRecord.connected_to(role: :writing) do
        UserAppPreference.create!(user_id: @user.id, app_preference_id: @new_preference.id)
      end

      result = @adoption.send(:find_last_linked_preference, @user)

      assert_equal @new_preference, result
    end

    # --- restore_preference_from! ---

    test "restore_preference_from! copies child record option_ids from source to target" do
      create_child_record!(@preference, :language, AppPreferenceLanguageOption::EN)
      target_lang = create_child_record!(@new_preference, :language, AppPreferenceLanguageOption::JA)

      adoption = build_adoption_context(@new_preference)
      adoption.send(:restore_preference_from!, @preference)

      target_lang.reload

      assert_equal AppPreferenceLanguageOption::EN, target_lang.option_id
    end

    test "restore_preference_from! does not raise when source has no child records" do
      create_child_record!(@new_preference, :language, AppPreferenceLanguageOption::JA)

      adoption = build_adoption_context(@new_preference)

      assert_nothing_raised do
        adoption.send(:restore_preference_from!, @preference)
      end
    end

    # --- adopt_preference_for! (integration) ---

    test "adopt_preference_for! links preference on first login" do
      assert_difference "UserAppPreference.count", 1 do
        @adoption.send(:adopt_preference_for!, @user)
      end
    end

    test "adopt_preference_for! restores and links on subsequent login" do
      create_child_record!(@preference, :language, AppPreferenceLanguageOption::EN)

      # Simulate first login link
      PreferenceRecord.connected_to(role: :writing) do
        UserAppPreference.create!(user_id: @user.id, app_preference_id: @preference.id)
      end

      # Now login with new preference
      target_lang = create_child_record!(@new_preference, :language, AppPreferenceLanguageOption::JA)
      adoption = build_adoption_context(@new_preference)

      adoption.send(:adopt_preference_for!, @user)

      target_lang.reload

      assert_equal AppPreferenceLanguageOption::EN, target_lang.option_id
      assert UserAppPreference.exists?(user_id: @user.id, app_preference_id: @new_preference.id)
    end

    test "adopt_preference_for! does not raise on error" do
      adoption = build_adoption_context(@preference)
      adoption.define_singleton_method(:adoptable_preference_class?) { raise StandardError, "boom" }

      assert_nothing_raised do
        adoption.send(:adopt_preference_for!, @user)
      end
    end

    test "adopt_preference_for! is no-op when resource is blank" do
      assert_no_difference "UserAppPreference.count" do
        @adoption.send(:adopt_preference_for!, nil)
      end
    end

    # --- adopt_rotated_preference! ---

    test "adopt_rotated_preference! links the new preference" do
      assert_difference "UserAppPreference.count", 1 do
        @adoption.send(:adopt_rotated_preference!, @user, @new_preference)
      end
    end

    test "adopt_rotated_preference! does not raise on error" do
      adoption = build_adoption_context(@preference)
      adoption.define_singleton_method(:adoptable_preference_class?) { raise StandardError, "boom" }

      assert_nothing_raised do
        adoption.send(:adopt_rotated_preference!, @user, @new_preference)
      end
    end

    test "adopt_rotated_preference! is no-op when resource is blank" do
      assert_no_difference "UserAppPreference.count" do
        @adoption.send(:adopt_rotated_preference!, nil, @new_preference)
      end
    end

    private

    def build_adoption_context(preference, preference_class_name: "AppPreference")
      pref_class = preference_class_name.constantize
      ctx = Object.new
      ctx.extend(Preference::Adoption)

      ctx.define_singleton_method(:preference_class) { pref_class }
      ctx.instance_variable_set(:@preferences, preference)

      # Stub issue_access_token_from as no-op (JWT issuance not under test)
      ctx.define_singleton_method(:issue_access_token_from) { |_pref| nil }

      ctx
    end

    def create_child_record!(preference, type, option_id)
      klass = "AppPreference#{type.to_s.capitalize}".constantize
      PreferenceRecord.connected_to(role: :writing) do
        klass.create!(preference_id: preference.id, option_id: option_id)
      end
    end
  end
end
