# frozen_string_literal: true

# == Schema Information
#
# Table name: divisions
#
#  id                 :uuid             not null, primary key
#  division_status_id :string(255)      not null
#  parent_id          :uuid
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_divisions_on_division_status_id  (division_status_id)
#  index_divisions_unique                 (parent_id,division_status_id) UNIQUE
#

require "test_helper"

class DivisionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
