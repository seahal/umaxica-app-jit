# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_statuses
# Database name: guest
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_org_contact_statuses_on_id  (id) UNIQUE
#

require "test_helper"

class OrgContactStatusTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgContactStatus
    @valid_id = "ACTIVE".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = OrgContactStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
