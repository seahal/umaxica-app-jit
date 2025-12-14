require "test_helper"

module ContactStatusModelTestHelper
  extend ActiveSupport::Concern

  included do
    test "id is converted to uppercase before validation" do
      model = @model_class.new(title: "lowercase")
      model.valid?

      assert_equal "LOWERCASE", model.title
    end

    test "id format validation allows A-Z0-9_" do
      model = @model_class.new(title: "VALID_ID_123")

      assert model.valid? || model.errors[:title].empty?
    end

    test "id format validation rejects invalid characters" do
      model = @model_class.new(title: "INVALID-ID")

      assert_not model.valid?
      assert_not_empty model.errors[:title]
    end

    test "id uniqueness is case insensitive" do
      # Create a record first
      @model_class.create!(title: "UNIQUE_TEST")

      # Try to create another with different case
      duplicate = @model_class.new(title: "unique_test")

      assert_not duplicate.valid?
      assert_not_empty duplicate.errors[:title]
    end
  end
end
