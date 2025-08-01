# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_emails
#
#  id         :binary           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid_id    :uuid             not null
#
require "test_helper"

class StaffTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  # ... some tests are written at emails_test.rb
end
