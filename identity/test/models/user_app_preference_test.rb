# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_app_preferences
# Database name: principal
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  app_preference_id :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_user_app_preferences_on_app_preference_id              (app_preference_id)
#  index_user_app_preferences_on_user_id_and_app_preference_id  (user_id,app_preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_preference_id => app_preferences.id) ON DELETE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
require "test_helper"

class UserAppPreferenceTest < ActiveSupport::TestCase
  test "class is defined" do
    assert_equal "UserAppPreference", UserAppPreference.name
  end
end
