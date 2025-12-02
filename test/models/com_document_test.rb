# frozen_string_literal: true

require "test_helper"

class ComDocumentTest < ActiveSupport::TestCase
  test "ComDocument class exists" do
    assert_kind_of Class, ComDocument
  end

  test "ComDocument inherits from BusinessesRecord" do
    assert_operator ComDocument, :<, BusinessesRecord
  end
end
