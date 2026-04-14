# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_telephones
# Database name: guest
#
#  id                      :bigint           not null, primary key
#  hotp_counter            :integer
#  hotp_secret             :string
#  telephone_number        :string(1000)     default(""), not null
#  telephone_number_bidx   :string
#  telephone_number_digest :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  com_contact_id          :bigint           default(0), not null
#
# Indexes
#
#  index_com_contact_telephones_on_com_contact_id_unique    (com_contact_id) UNIQUE
#  index_com_contact_telephones_on_telephone_number         (telephone_number)
#  index_com_contact_telephones_on_telephone_number_bidx    (telephone_number_bidx) UNIQUE WHERE (telephone_number_bidx IS NOT NULL)
#  index_com_contact_telephones_on_telephone_number_digest  (telephone_number_digest) UNIQUE WHERE (telephone_number_digest IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#
require "test_helper"

class ComContactTelephoneTest < ActiveSupport::TestCase
  fixtures :com_contact_categories, :com_contact_statuses

  test "should inherit from GuestRecord" do
    assert_operator ComContactTelephone, :<, GuestRecord
  end

  test "should belong to com_contact" do
    contact = create_contact(public_id: "phone_1")
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15551234567",
    )

    assert_respond_to telephone, :com_contact
    assert_not_nil telephone.com_contact
    assert_kind_of ComContact, telephone.com_contact
  end

  test "should encrypt telephone_number" do
    contact = create_contact(public_id: "phone_2")
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15551234568",
    )

    # Read directly from database to check encryption
    raw_value = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = #{telephone.id}",
    ).first["telephone_number"]

    # Encrypted value should be different from plaintext
    assert_not_equal "+15551234568", raw_value
    # But the model should decrypt it correctly
    assert_equal "+15551234568", telephone.reload.telephone_number
  end

  test "should support deterministic encryption for telephone_number" do
    contact1 = create_contact(public_id: "phone_3")

    # Create first record
    telephone1 = ComContactTelephone.create!(
      com_contact: contact1,
      telephone_number: "+15551234569",
    )

    # Record first raw value
    raw1 = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = #{telephone1.id}",
    ).first["telephone_number"]

    # Destroy first record to avoid uniqueness violation when creating the second one
    telephone1.destroy!

    contact2 = create_contact(public_id: "phone_4")

    # Create second record with the same telephone number
    telephone2 = ComContactTelephone.create!(
      com_contact: contact2,
      telephone_number: "+15551234569",
    )

    # Record second raw value
    raw2 = ComContactTelephone.connection.execute(
      "SELECT telephone_number FROM com_contact_telephones WHERE id = #{telephone2.id}",
    ).first["telephone_number"]

    assert_equal raw1, raw2
  end

  test "should have valid fixtures" do
    contact = create_contact(public_id: "phone_5")
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15550000000",
    )

    assert_predicate telephone, :valid?
  end

  test "should use bigint as primary key" do
    contact = create_contact(public_id: "phone_6")
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15551111111",
    )

    assert_kind_of Integer, telephone.id
  end

  test "should have timestamps" do
    contact = create_contact(public_id: "phone_7")
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15552222222",
    )

    assert_respond_to telephone, :created_at
    assert_respond_to telephone, :updated_at
    assert_not_nil telephone.created_at
    assert_not_nil telephone.updated_at
  end

  test "should have all expected attributes" do
    contact = create_contact(public_id: "phone_8")
    telephone = ComContactTelephone.create!(
      com_contact: contact,
      telephone_number: "+15553333333",
    )

    assert_respond_to telephone, :telephone_number
    assert_respond_to telephone, :com_contact_id
    assert_respond_to telephone, :hotp_secret
    assert_respond_to telephone, :hotp_counter
  end

  # Validation tests
  test "should validate presence of telephone_number" do
    contact = create_contact(public_id: "phone_10")
    telephone = ComContactTelephone.new(
      com_contact: contact,
    )

    assert_not telephone.valid?
    assert_predicate telephone.errors[:telephone_number], :any?, "telephone_number should have validation errors"
  end

  test "should validate format of telephone_number" do
    # Invalid telephone formats
    invalid_phones = ["abc", "123-abc-4567", "!!!"]
    invalid_phones.each_with_index do |invalid_phone, i|
      contact = create_contact(public_id: "phone_inv_#{i}")
      telephone = ComContactTelephone.new(
        com_contact: contact,
        telephone_number: invalid_phone,
      )

      assert_not telephone.valid?, "#{invalid_phone} should be invalid"
      assert_predicate telephone.errors[:telephone_number], :any?, "#{invalid_phone} should have validation errors"
    end

    # Valid telephone formats
    valid_phones = ["+1234567890", "+1-123-456-7890", "+1 (123) 456-7890", "+81 90 1234 5678"]
    valid_phones.each_with_index do |valid_phone, i|
      contact = create_contact(public_id: "phone_val_#{i}")
      telephone = ComContactTelephone.new(
        com_contact: contact,
        telephone_number: valid_phone,
      )

      assert_predicate telephone, :valid?, "#{valid_phone} should be valid"
    end
  end

  private

  def create_contact(attrs = {})
    ComContact.create!(
      {
        confirm_policy: "1",
        category_id: ComContactCategory::SECURITY_ISSUE,
        status_id: ComContactStatus::NOTHING,
      }.merge(attrs),
    )
  end
end
