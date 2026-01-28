# == Schema Information
#
# Table name: com_preference_regions
# Database name: preference
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :string           not null
#  preference_id :uuid             not null
#
# Indexes
#
#  index_com_preference_regions_on_option_id      (option_id)
#  index_com_preference_regions_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (option_id => com_preference_region_options.id)
#  fk_rails_...  (preference_id => com_preferences.id)
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceRegionTest < ActiveSupport::TestCase
  setup do
    @preference = ComPreference.create!
  end

  test "belongs to preference" do
    I18n.with_locale(:ja) do
      region = ComPreferenceRegion.new
      assert_not region.valid?
      assert_includes region.errors[:preference], "を入力してください"
    end
  end

  test "can be created with preference and option" do
    option = com_preference_region_options(:jp)
    region = ComPreferenceRegion.create!(preference: @preference, option: option)
    assert_not_nil region.id
    assert_equal @preference, region.preference
    assert_equal option, region.option
  end

  test "sets default option_id on create" do
    region = ComPreferenceRegion.create!(preference: @preference)
    assert_equal "JP", region.option_id
  end
end
