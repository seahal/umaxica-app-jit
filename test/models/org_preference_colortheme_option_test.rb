# == Schema Information
#
# Table name: org_preference_colortheme_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer          not null
#
# Indexes
#
#  org_preference_colortheme_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class OrgPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = OrgPreferenceColorthemeOption.create!(id: "TEST_ORG_COLORTHEME")
    assert_not_nil option.id
  end

  test "has many org_preference_colorthemes" do
    option = OrgPreferenceColorthemeOption.create!(id: "TEST_ORG_COLORTHEME")
    preference = OrgPreference.create!
    colortheme = OrgPreferenceColortheme.create!(preference: preference, option: option)
    assert_includes option.org_preference_colorthemes, colortheme
  end

  test "restricts deletion when associated records exist" do
    option = OrgPreferenceColorthemeOption.create!(id: "TEST_ORG_COLORTHEME")
    preference = OrgPreference.create!
    OrgPreferenceColortheme.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "validates id format" do
    option = OrgPreferenceColorthemeOption.new(id: "invalid-id")
    assert_not option.valid?
    assert_not_empty option.errors[:id]

    option.id = "VALID_ID"
    assert_predicate option, :valid?
  end

  test "validates length of id" do
    record = OrgPreferenceColorthemeOption.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
