# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_telephones
# Database name: guest
#
#  id                      :bigint           not null, primary key
#  telephone_number        :string(1000)     default(""), not null
#  telephone_number_bidx   :string
#  telephone_number_digest :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  app_contact_id          :bigint           default(0), not null
#
# Indexes
#
#  index_app_contact_telephones_on_app_contact_id           (app_contact_id)
#  index_app_contact_telephones_on_telephone_number         (telephone_number)
#  index_app_contact_telephones_on_telephone_number_bidx    (telephone_number_bidx) UNIQUE WHERE (telephone_number_bidx IS NOT NULL)
#  index_app_contact_telephones_on_telephone_number_digest  (telephone_number_digest) UNIQUE WHERE (telephone_number_digest IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (app_contact_id => app_contacts.id)
#

require "test_helper"

class AppContactTelephoneTest < ActiveSupport::TestCase
  fixtures :app_contacts, :app_contact_telephones

  def setup
    @app_contact = AppContact.find_by!(public_id: "one_app_contact_00001")
    @telephone = AppContactTelephone.new(
      app_contact: @app_contact,
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

  test "should validate telephone format" do
    valid_numbers = %w(+12125551234 090-1234-5678 03-1234-5678)
    valid_numbers.each do |num|
      @telephone.telephone_number = num

      assert_predicate @telephone, :valid?, "#{num.inspect} should be valid"
    end
  end

  test "should encrypt telephone_number" do
    skip "ActiveRecord Encryption is not configured in test environment"
    @telephone.save!

    assert_not_equal "+819012345678", @telephone.reload[:telephone_number]
    assert_equal "+819012345678", @telephone.telephone_number
  end

  test "should belong to app_contact" do
    @telephone.save!

    assert_equal @app_contact, @telephone.app_contact
  end
end
