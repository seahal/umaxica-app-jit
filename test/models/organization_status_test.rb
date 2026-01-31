# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_statuses
# Database name: operator
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_department_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
require "test_helper"

class OrganizationStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validates length of id" do
    record = OrganizationStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
