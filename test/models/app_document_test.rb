# frozen_string_literal: true

require "test_helper"

class AppDocumentTest < ActiveSupport::TestCase
  test "AppDocument class exists" do
    assert_kind_of Class, AppDocument
  end

  test "AppDocument inherits from BusinessesRecord" do
    assert_operator AppDocument, :<, BusinessesRecord
  end
end
