# typed: false
# frozen_string_literal: true

require "test_helper"

module Contact
  class InquiryContextTest < ActiveSupport::TestCase
    test "defaults to guest on com without actor" do
      context = Contact::InquiryContext.build(surface: :com)

      assert_predicate context, :com?
      assert_predicate context, :guest?
      assert_not context.authenticated?
      assert_nil context.actor
    end

    test "defaults to identified member when user is present" do
      user = Struct.new(:id).new(1)
      context = Contact::InquiryContext.build(surface: :app, current_user: user)

      assert_predicate context, :app?
      assert_predicate context, :identified_member?
      assert_predicate context, :authenticated?
      assert_equal user, context.actor
    end

    test "allows explicit anonymous member mode" do
      user = Struct.new(:id).new(1)
      context = Contact::InquiryContext.build(surface: :app, current_user: user, mode: :anonymous_member)

      assert_predicate context, :anonymous_member?
      assert_predicate context, :authenticated?
      assert_equal user, context.actor
    end

    test "raises on unsupported surface" do
      error =
        assert_raises(ArgumentError) do
          Contact::InquiryContext.build(surface: :docs)
        end

      assert_match(/unsupported inquiry surface/, error.message)
    end
  end
end
