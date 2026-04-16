# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_emails
# Database name: guest
#
#  id                   :bigint           not null, primary key
#  email_address        :string(1000)     default(""), not null
#  email_address_bidx   :string
#  email_address_digest :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  app_contact_id       :bigint           default(0), not null
#
# Indexes
#
#  index_app_contact_emails_on_app_contact_id        (app_contact_id)
#  index_app_contact_emails_on_email_address         (email_address)
#  index_app_contact_emails_on_email_address_bidx    (email_address_bidx) UNIQUE WHERE (email_address_bidx IS NOT NULL)
#  index_app_contact_emails_on_email_address_digest  (email_address_digest) UNIQUE WHERE (email_address_digest IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (app_contact_id => app_contacts.id)
#

require "test_helper"

class AppContactEmailTest < ActiveSupport::TestCase
  fixtures :app_contact_categories, :app_contact_statuses

  setup do
    @app_contact = AppContact.create!(
      public_id: "test_contact_1",
      confirm_policy: "1",
      category_id: app_contact_categories(:application_inquiry).id,
      status_id: app_contact_statuses(:NOTHING).id,
    )

    @email = AppContactEmail.new(
      app_contact: @app_contact,
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
    valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn)
    valid_addresses.each do |valid_address|
      @email.email_address = valid_address

      assert_predicate @email, :valid?, "#{valid_address.inspect} should be valid"
    end

    invalid_addresses = %w(user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com)
    invalid_addresses.each do |invalid_address|
      @email.email_address = invalid_address

      assert_not @email.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "should downcase email before save" do
    @email.email_address = "FooBar@Example.Com"
    @email.save!

    assert_equal "foobar@example.com", @email.reload.email_address
  end

  test "should encrypt email_address" do
    @email.save!

    raw_data = AppContactEmail.connection.select_one(
      "SELECT email_address FROM app_contact_emails WHERE id = #{@email.id}",
    )

    assert_not_equal "test@example.com", raw_data["email_address"]
    assert_equal "test@example.com", @email.email_address
  end

  test "should belong to app_contact" do
    @email.save!

    assert_equal @app_contact, @email.app_contact
  end
end
