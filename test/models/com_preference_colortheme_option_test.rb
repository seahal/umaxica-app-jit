# == Schema Information
#
# Table name: com_preference_colortheme_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_preference_colortheme_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceColorthemeOptionTest < ActiveSupport::TestCase
  test "can be created" do
    option = ComPreferenceColorthemeOption.create!(id: "TEST_COM_COLORTHEME")
    assert_not_nil option.id
  end

  test "has many com_preference_colorthemes" do
    option = ComPreferenceColorthemeOption.create!(id: "TEST_COM_COLORTHEME")
    preference = ComPreference.create!
    colortheme = ComPreferenceColortheme.create!(preference: preference, option: option)
    assert_includes option.com_preference_colorthemes, colortheme
  end

  test "restricts deletion when associated records exist" do
    option = ComPreferenceColorthemeOption.create!(id: "TEST_COM_COLORTHEME")
    preference = ComPreference.create!
    ComPreferenceColortheme.create!(preference: preference, option: option)

    assert_raises(ActiveRecord::RecordNotDestroyed) do
      option.destroy!
    end
  end

  test "validates id format" do
    option = ComPreferenceColorthemeOption.new(id: "invalid-id")
    assert_not option.valid?
    assert_not_empty option.errors[:id]

    option.id = "VALID_ID"
    assert_predicate option, :valid?
  end

  test "validates length of id" do
    record = ComPreferenceColorthemeOption.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
