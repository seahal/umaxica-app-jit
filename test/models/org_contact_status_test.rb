# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class OrgContactStatusTest < ActiveSupport::TestCase
  setup do
    @model_class = OrgContactStatus
    @valid_id = OrgContactStatus::NOTHING
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = OrgContactStatus.new(id: 2)

    assert_predicate record, :valid?
  end
end
