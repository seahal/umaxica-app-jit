# == Schema Information
#
# Table name: client_statuses
# Database name: principal
#
#  id :string(255)      default("NEYO"), not null, primary key
#
# Indexes
#
#  index_client_identity_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#

# frozen_string_literal: true

require "test_helper"

class ClientStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validates length of id" do
    record = ClientStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
