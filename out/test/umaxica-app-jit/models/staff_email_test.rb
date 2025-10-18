# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#
# Indexes
#
#  index_staff_emails_on_staff_id  (staff_id)
#
require "test_helper"

class StaffTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  # ... some tests are written at emails_test.rb
end
