# frozen_string_literal: true

# == Schema Information
#
# Table name: emails
#
#  id             :binary           default(""), not null, primary key
#  address        :string(1024)     not null
#  emailable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  emailable_id   :binary           not null
#
require "test_helper"

class AccountTest < ActiveSupport::TestCase
  [ StaffIdentityEmail, UserIdentityEmail ].each do |model|
    test "#{model} valid with address and confirm_policy" do
      record = model.new(address: "eg@example.com", confirm_policy: true)

      assert_predicate record, :valid?
      assert_difference "#{model}.count", +1 do
        record.save!
      end
    end

    test "#{model} rejects blank address" do
      assert_not model.new(address: "", confirm_policy: true).valid?
    end

    test "#{model} enforces case-insensitive uniqueness" do
      model.create!(address: "eg@example.com", confirm_policy: true)

      assert_not model.new(address: "eg@example.com", confirm_policy: true).valid?
      assert_not model.new(address: "EG@EXAMPLE.COM", confirm_policy: true).valid?
    end

    test "#{model} downcases address on save" do
      mail_address = "A@B.C"
      rec = model.create!(address: mail_address, confirm_policy: true)

      assert_equal mail_address.downcase, rec.reload.address
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "#{model} pass_code validations when address nil" do
      m = model.new(address: nil)
      m.pass_code = 123456

      assert_predicate m, :valid?
      m.pass_code = 12345

      assert_not m.valid?
      m.pass_code = 1234567

      assert_not m.valid?
      m.pass_code = 0

      assert_not m.valid?
      m.pass_code = nil

      assert_not m.valid?
    end
    # rubocop:enable Minitest/MultipleAssertions

    test "#{model} invalid when both address and pass_code nil" do
      m = model.new(address: nil, pass_code: nil)

      assert_not m.valid?
    end
  end
end
