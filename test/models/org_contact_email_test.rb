# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_emails
# Database name: guest
#
#  id                   :bigint           not null, primary key
#  email_address        :string(1000)     default(""), not null
#  email_address_bidx   :string
#  email_address_digest :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  org_contact_id       :bigint           default(0), not null
#
# Indexes
#
#  index_org_contact_emails_on_email_address         (email_address)
#  index_org_contact_emails_on_email_address_bidx    (email_address_bidx) UNIQUE WHERE (email_address_bidx IS NOT NULL)
#  index_org_contact_emails_on_email_address_digest  (email_address_digest) UNIQUE WHERE (email_address_digest IS NOT NULL)
#  index_org_contact_emails_on_org_contact_id        (org_contact_id)
#
# Foreign Keys
#
#  fk_rails_...  (org_contact_id => org_contacts.id)
#
require "test_helper"

class OrgContactEmailTest < ActiveSupport::TestCase
  fixtures :org_contacts, :org_contact_categories, :org_contact_statuses

  def setup
    @org_contact = org_contacts(:one)
    @email = OrgContactEmail.new(
      org_contact: @org_contact,
      email_address: "test@example.com",
    )
  end

  test "should be valid" do
    assert_predicate @email, :valid?
  end

  test "should require email_address" do
    @email.email_address = nil

    assert_not @email.valid?
  end

  test "should validate email format" do
    valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp)
    valid_addresses.each do |valid_address|
      @email.email_address = valid_address

      assert_predicate @email, :valid?, "#{valid_address.inspect} should be valid"
    end

    invalid_addresses = %w(user@example,com user_at_foo.org user.name@example.)
    invalid_addresses.each do |invalid_address|
      @email.email_address = invalid_address

      assert_not @email.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
end
