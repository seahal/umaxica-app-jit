# typed: false
# frozen_string_literal: true

require "test_helper"

class TreeableTest < ActiveSupport::TestCase
  include TreeableSharedTests

  test "treeable class is defined" do
    assert_equal AppDocumentCategoryMaster, treeable_class
  end

  private

  def treeable_class
    AppDocumentCategoryMaster
  end
end
