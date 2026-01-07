# == Schema Information
#
# Table name: com_preference_colorthemes
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  option_id     :uuid
#
# Indexes
#
#  index_com_preference_colorthemes_on_option_id      (option_id)
#  index_com_preference_colorthemes_on_preference_id  (preference_id)
#

# frozen_string_literal: true

require "test_helper"

class ComPreferenceColorthemeTest < ActiveSupport::TestCase
  setup do
    @preference = ComPreference.create!
  end

  test "belongs to preference" do
    colortheme = ComPreferenceColortheme.new
    assert_not colortheme.valid?
    assert_includes colortheme.errors[:preference], "を入力してください"
  end

  test "can be created with preference" do
    colortheme = ComPreferenceColortheme.create!(preference: @preference)
    assert_not_nil colortheme.id
    assert_equal @preference, colortheme.preference
  end

  test "can be created with option" do
    option = ComPreferenceColorthemeOption.create!
    colortheme = ComPreferenceColortheme.create!(preference: @preference, option: option)
    assert_equal option, colortheme.option
  end

  test "can be created without option" do
    colortheme = ComPreferenceColortheme.create!(preference: @preference)
    assert_nil colortheme.option
  end
end
