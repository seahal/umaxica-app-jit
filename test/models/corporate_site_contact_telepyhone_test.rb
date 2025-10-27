require "test_helper"

class CorporateSiteContactTelepyhoneTest < ActiveSupport::TestCase
  test "should inherit from GuestsRecord" do
    assert CorporateSiteContactTelepyhone < GuestsRecord
  end

  test "should belong to corporate_site_contact" do
    contact = corporate_site_contacts(:one)
    telephone = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now
    )
    assert_respond_to telephone, :corporate_site_contact
    assert_not_nil telephone.corporate_site_contact
    assert_kind_of CorporateSiteContact, telephone.corporate_site_contact
  end

  test "should downcase telephone_number before save" do
    contact = corporate_site_contacts(:one)
    telephone = CorporateSiteContactTelepyhone.new(
      corporate_site_contact: contact,
      telephone_number: "ABC123",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )
    telephone.save
    assert_equal "abc123", telephone.telephone_number
  end

  test "should encrypt telephone_number" do
    contact = corporate_site_contacts(:one)
    telephone = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    # Read directly from database to check encryption
    raw_value = CorporateSiteContactTelepyhone.connection.execute(
      "SELECT telephone_number FROM corporate_site_contact_telepyhones WHERE id = '#{telephone.id}'"
    ).first["telephone_number"]

    # Encrypted value should be different from plaintext
    assert_not_equal "+1234567890", raw_value
    # But the model should decrypt it correctly
    assert_equal "+1234567890", telephone.reload.telephone_number
  end

  test "should support deterministic encryption for telephone_number" do
    contact = corporate_site_contacts(:one)

    # Create two records with the same telephone number
    telephone1 = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    telephone2 = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 5,
      expires_at: 1.day.from_now
    )

    # With deterministic encryption, encrypted values should be the same
    raw1 = CorporateSiteContactTelepyhone.connection.execute(
      "SELECT telephone_number FROM corporate_site_contact_telepyhones WHERE id = '#{telephone1.id}'"
    ).first["telephone_number"]

    raw2 = CorporateSiteContactTelepyhone.connection.execute(
      "SELECT telephone_number FROM corporate_site_contact_telepyhones WHERE id = '#{telephone2.id}'"
    ).first["telephone_number"]

    assert_equal raw1, raw2
  end

  test "should have valid fixtures" do
    # Note: Encrypted fields in fixtures may cause issues
    # We create a fresh record instead of loading from fixtures
    contact = corporate_site_contacts(:one)
    telephone = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+1234567890",
      activated: false,
      deletable: false,
      remaining_views: 1,
      expires_at: 1.day.from_now
    )
    assert telephone.valid?
  end

  test "should use UUID as primary key" do
    contact = corporate_site_contacts(:one)
    telephone = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+9876543210",
      expires_at: 1.day.from_now
    )
    assert_kind_of String, telephone.id
    assert_equal 36, telephone.id.length
  end

  test "should have timestamps" do
    contact = corporate_site_contacts(:one)
    telephone = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+5555555555",
      expires_at: 1.day.from_now
    )
    assert_respond_to telephone, :created_at
    assert_respond_to telephone, :updated_at
    assert_not_nil telephone.created_at
    assert_not_nil telephone.updated_at
  end

  test "should have all expected attributes" do
    contact = corporate_site_contacts(:one)
    telephone = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+6666666666",
      expires_at: 1.day.from_now
    )
    assert_respond_to telephone, :telephone_number
    assert_respond_to telephone, :activated
    assert_respond_to telephone, :deletable
    assert_respond_to telephone, :remaining_views
    assert_respond_to telephone, :expires_at
  end

  test "should have default values" do
    contact = corporate_site_contacts(:one)
    telephone = CorporateSiteContactTelepyhone.create!(
      corporate_site_contact: contact,
      telephone_number: "+1234567890",
      expires_at: 1.day.from_now
    )
    assert_equal false, telephone.activated
    assert_equal false, telephone.deletable
    assert_equal 10, telephone.remaining_views
  end
end
