ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

ActiveSupport.on_load(:active_record) do
  [
    ActivityRecord, AvatarRecord, BehaviorRecord, BillingRecord, CommerceRecord,
    GuestRecord, MessageRecord, NotificationRecord, OccurrenceRecord, OperatorRecord,
    PrincipalRecord, PublicationRecord, SearchRecord, SettingRecord, TokenRecord
  ].each do |record_class|
    record_class.establish_connection :test if defined?(record_class)
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :users, :user_identity_statuses, :user_identity_emails, :user_identity_telephones,
             :staffs, :staff_identity_statuses, :staff_identity_emails, :staff_identity_telephones,
             :user_activity_events, :user_activity_levels,
             :staff_activity_events, :staff_activity_levels,
             :email_occurrence_statuses, :telephone_occurrence_statuses, :zip_occurrence_statuses,
             :app_preferences, :user_preferences, :staff_preferences,
             :organizations, :organization_statuses, :workspaces, :workspace_statuses
  end
end
