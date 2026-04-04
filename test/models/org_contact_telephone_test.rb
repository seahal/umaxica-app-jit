# typed: false
# frozen_string_literal: true

require "test_helper"

class OrgContactTelephoneTest < ActiveSupport::TestCase
  def setup
    @org_contact = OrgContact.find_by!(public_id: "test_org_contact_0001")
    @telephone = OrgContactTelephone.new(
      org_contact: @org_contact,
      telephone_number: "+819012345678",
    )
  end

  test "should be valid" do
    assert_predicate @telephone, :valid?
  end

  test "should require telephone_number" do
    @telephone.telephone_number = nil

    assert_not @telephone.valid?
  end
end
