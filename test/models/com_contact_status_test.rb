# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_statuses
# Database name: guest
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_com_contact_statuses_on_id  (id) UNIQUE
#

require "test_helper"

class ComContactStatusTest < ActiveSupport::TestCase
  setup do
    @model_class = ComContactStatus
    @valid_id = "ACTIVE".freeze
    @subject = @model_class.new(id: @valid_id)
  end

  test "validates length of id" do
    record = ComContactStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
