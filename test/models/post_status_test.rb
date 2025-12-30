# frozen_string_literal: true

# == Schema Information
#
# Table name: post_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class PostStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = PostStatus.new
    assert_predicate status, :valid?
  end
end
