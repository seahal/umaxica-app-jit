require "test_helper"

module ContactStatusModelTestHelper
  extend ActiveSupport::Concern

  included do
    test "id is converted to uppercase before validation" do
      model = @model_class.new(id: "lowercase")
      model.valid?

      assert_equal "LOWERCASE", model.id
    end

    test "id format validation allows A-Z0-9_" do
      model = @model_class.new(id: "VALID_ID_123")

      assert model.valid? || model.errors[:id].empty?
    end

    test "id format validation rejects invalid characters" do
      model = @model_class.new(id: "INVALID-ID")

      assert_not model.valid?
      assert_not_empty model.errors[:id]
    end

    test "id uniqueness is case insensitive" do
      # Create a record first
      @model_class.create!(id: "UNIQUE_TEST")

      # Try to create another with different case
      duplicate = @model_class.new(id: "unique_test")

      assert_not duplicate.valid?
      assert_not_empty duplicate.errors[:id]
    end
  end
end
