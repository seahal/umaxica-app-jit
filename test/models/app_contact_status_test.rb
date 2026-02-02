# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_statuses
# Database name: guest
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_contact_statuses_on_code  (code) UNIQUE
#

require "test_helper"

class AppContactStatusTest < ActiveSupport::TestCase
  def setup
    @model_class = AppContactStatus
    @status = AppContactStatus.find_or_create_by!(id: "ACTIVE")
    @contact = AppContact.create!(
      app_contact_status: @status,
    )
  end

  test "should have many app_contacts" do
    assert_includes @status.app_contacts, @contact
  end

  test "should restrict destroy when app_contacts exist" do
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      @status.destroy
    end
  end

  test "validates length of id" do
    record = AppContactStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
