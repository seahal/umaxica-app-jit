# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_telephones
# Database name: guest
#
#  id                      :bigint           not null, primary key
#  telephone_number        :string(1000)     default(""), not null
#  telephone_number_bidx   :string
#  telephone_number_digest :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  org_contact_id          :bigint           default(0), not null
#
# Indexes
#
#  index_org_contact_telephones_on_org_contact_id           (org_contact_id)
#  index_org_contact_telephones_on_telephone_number         (telephone_number)
#  index_org_contact_telephones_on_telephone_number_bidx    (telephone_number_bidx) UNIQUE WHERE (telephone_number_bidx IS NOT NULL)
#  index_org_contact_telephones_on_telephone_number_digest  (telephone_number_digest) UNIQUE WHERE (telephone_number_digest IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (org_contact_id => org_contacts.id)
#
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
