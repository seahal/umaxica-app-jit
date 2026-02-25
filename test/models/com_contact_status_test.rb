# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#

require "test_helper"

class ComContactStatusTest < ActiveSupport::TestCase
  setup do
    @model_class = ComContactStatus
    @valid_id = ComContactStatus::NEYO
    @subject = @model_class.new(id: @valid_id)
  end

  test "accepts integer ids" do
    record = ComContactStatus.new(id: 2)

    assert_predicate record, :valid?
  end
end
