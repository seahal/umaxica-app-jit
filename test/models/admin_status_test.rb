# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_statuses
# Database name: operator
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_admin_identity_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
require "test_helper"

class AdminStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validates length of id" do
    record = AdminStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
