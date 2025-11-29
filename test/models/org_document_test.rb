# frozen_string_literal: true

require "test_helper"

class OrgDocumentTest < ActiveSupport::TestCase
  test "OrgDocument class exists" do
    assert_kind_of Class, OrgDocument
  end

  test "OrgDocument inherits from BusinessesRecord" do
    assert_operator OrgDocument, :<, BusinessesRecord
  end
end
