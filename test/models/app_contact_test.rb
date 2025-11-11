# == Schema Information
#
# Table name: app_contacts
#
#  id               :uuid             not null, primary key
#  description      :text
#  email_address    :string
#  ip_address       :cidr
#  telephone_number :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"


class AppContactTest < ActiveSupport::TestCase
  [ AppContact ].each do |model|
    setup do
      @good_pattern = model.new(
        confirm_policy: true,
        email_address: "eg@example.com",
        telephone_number: "+819012345678",
        email_pass_code: 123456,
        telephone_pass_code: 123456,
        title: "good title",
        description: "good description"
      )
    end

    test "good #{model}'s email pattern" do
      assert_predicate @good_pattern, :valid?
      assert @good_pattern.save
      @good_pattern.email_address = "x@example.net"

      assert_predicate @good_pattern, :valid?
    end

    test "valid #{model}'s confirmation check" do
      assert_predicate @good_pattern, :valid?
      @good_pattern.confirm_policy = false

      assert_not @good_pattern.valid?
      @good_pattern.confirm_policy = nil

      assert_predicate @good_pattern, :valid?
    end

    test "invalid #{model}'s email patterns" do
      [ nil, "", "example..com", "exampleexample.com", "xample@#example.jp", "@example.com" ].each do
        @good_pattern.email_address = it

        assert_not @good_pattern.valid?
      end
    end

    test "valid #{model}'s email patterns" do
      [ "example@example.org" ].each do |chars|
        @good_pattern.email_address = chars

        assert_predicate @good_pattern, :valid?
      end
    end

    test "invalid #{model}'s telephone number patterns" do
      [ "", nil, "+810901234", "81901234" ].each do
        @good_pattern.email_address = it

        assert_not @good_pattern.valid?
      end
    end

    test "valid #{model}'s telephone number patterns" do
      [ "+811" ].each do
        @good_pattern.email_address = it

        assert_not @good_pattern.valid?
      end
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "good #{model}'s email otp password pattern" do
      assert_predicate model.new(email_pass_code: 123456), :valid?
      assert_predicate model.new(email_pass_code: nil), :valid?
      assert_not model.new(email_pass_code: 12345).valid?
      assert_not model.new(email_pass_code: 1234567).valid?
      assert_not model.new(email_pass_code: 0).valid?
      assert_not model.new(email_pass_code: 1).valid?
      assert_predicate model.new(email_pass_code: nil, telephone_pass_code: 123456), :valid?
    end
    # rubocop:enable Minitest/MultipleAssertions

    # rubocop:disable Minitest/MultipleAssertions
    test "good #{model}'s telephone otp password pattern" do
      assert_predicate model.new(telephone_pass_code: 123456), :valid?
      assert_predicate model.new(telephone_pass_code: nil), :valid?
      assert_not model.new(telephone_pass_code: 12345).valid?
      assert_not model.new(telephone_pass_code: 1234567).valid?
      assert_not model.new(telephone_pass_code: 0).valid?
      assert_not model.new(telephone_pass_code: 1).valid?
      assert_predicate model.new(email_pass_code: 123456, telephone_pass_code: nil), :valid?
    end
    # rubocop:enable Minitest/MultipleAssertions

    test "bad #{model}'s title pattern" do
      [ "", "a" * 7, "a" * 256 ].each do
        @good_pattern.title = it

        assert_not @good_pattern.valid?
      end
    end

    test "good #{model}'s title pattern" do
      [ "a" * 8, "a" * 255, nil ].each do
        @good_pattern.title = it

        assert_predicate @good_pattern, :valid?
      end
    end

    test "bad #{model}'s description pattern" do
      [ "", "a" * 7, "a" * 1024 ].each do
        @good_pattern.description = it

        assert_not @good_pattern.valid?
      end
    end

    test "good #{model}'s description pattern" do
      [ "a" * 8, "a" * 1023, nil ].each do
        @good_pattern.description = it

        assert_predicate @good_pattern, :valid?
      end
    end

    test "none is invalid of #{model}'s pattern" do
      assert_raises(RuntimeError) do
        AppContact.create
      end
    end

    # test "bad #{model}'s email pattern" do
    #   valid_telephone_number = "+81701232456789"
    #   assert_not model.new(email_address: "", telephone_number: valid_telephone_number).valid?
    # end
  end

  # Foreign key constraint tests
  test "should reference contact_category by title" do
    category = AppContactCategory.create!(title: "test_category")
    contact = AppContact.new(
      confirm_policy: true,
      email_address: "test@example.com",
      telephone_number: "+819012345678",
      email_pass_code: 123456,
      telephone_pass_code: 123456,
      title: "test title",
      description: "test description",
      contact_category_title: "test_category"
    )

    assert contact.save
    assert_equal "test_category", contact.contact_category_title
  end

  test "should reference contact_status by title" do
    status = AppContactStatus.create!(title: "test_status")
    contact = AppContact.new(
      confirm_policy: true,
      email_address: "test@example.com",
      telephone_number: "+819012345678",
      email_pass_code: 123456,
      telephone_pass_code: 123456,
      title: "test title",
      description: "test description",
      contact_status_title: "test_status"
    )

    assert contact.save
    assert_equal "test_status", contact.contact_status_title
  end

  test "should set default contact_category_title when nil" do
    contact = AppContact.new(
      confirm_policy: true,
      email_address: "test@example.com",
      telephone_number: "+819012345678",
      email_pass_code: 123456,
      telephone_pass_code: 123456,
      title: "test title",
      description: "test description",
      contact_category_title: nil
    )

    assert contact.save
    assert_equal "NULL_APP_CATEGORY", contact.contact_category_title
  end

  test "should set default contact_status_title when nil" do
    contact = AppContact.new(
      confirm_policy: true,
      email_address: "test@example.com",
      telephone_number: "+819012345678",
      email_pass_code: 123456,
      telephone_pass_code: 123456,
      title: "test title",
      description: "test description",
      contact_status_title: nil
    )

    assert contact.save
    assert_equal "NULL_CONTACT_STATUS", contact.contact_status_title
  end
end
