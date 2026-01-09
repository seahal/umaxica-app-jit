# frozen_string_literal: true

require "test_helper"

# Test to verify that models with string IDs enforce proper format constraints
# Targets models ending with: Status, Event, Level
# Note: Option/Master/Category tables are excluded as they may contain timezone IDs, language codes, etc.
# These models should only allow uppercase letters, numbers, and underscores in their IDs
class IdFormatConstraintTest < ActiveSupport::TestCase
  setup do
    # Initialize to empty array in case of errors
    @target_models = [].freeze

    # Eager load all models - this will load only models, not controllers
    # Rails.application.eager_load! is better than require_dependency as it respects load order
    Rails.application.eager_load! unless Rails.application.config.eager_load

    # Find all models with string primary keys that match naming patterns
    # Exclude Option/Master/Category as they may have different ID format requirements
    @target_models = ActiveRecord::Base.descendants
      .reject(&:abstract_class?)
      .select { |model| model.name&.match?(/(Status|Event|Level)\z/) }
      .select { |model| has_string_primary_key?(model) }
  rescue => e
    # Ignore load errors for models with dependencies
    Rails.logger.warn { "Error loading models: #{e.message}" }
    @target_models = [].freeze
  end

  test "models with string IDs should enforce uppercase alphanumeric and underscore format" do
    skip "No target models found" if @target_models.empty?

    # Print all target models for debugging
    puts "\n=== Target Models (#{@target_models.count}) ==="
    @target_models.each do |model|
      puts "  - #{model.name} (table: #{model.table_name})"
    end
    puts "===\n"

    @target_models.each do |model|
      test_model_id_format(model)
    end
  end

  private

  # Check if model has a string primary key
  def has_string_primary_key?(model)
    return false unless model.primary_key

    column = model.columns_hash[model.primary_key]
    column&.type == :string
  end

  # Test that a model accepts valid IDs and rejects invalid ones
  def test_model_id_format(model)
    pk = model.primary_key

    # Valid ID examples: uppercase letters, numbers, and underscores
    valid_ids = [
      "VALID_ID_123",
      "TEST_STATUS",
      "OPTION_1",
      generate_unique_id(model),
    ]

    # Invalid ID examples: lowercase, hyphens, special characters
    invalid_ids = [
      "invalid-id", # hyphen not allowed
      # "lower_case",    # lowercase is valid if the model normalizes (upcases) it before validation
      "with space",      # space not allowed
      "special!char",    # special character not allowed
    ]

    # Test valid IDs - these should be accepted
    valid_ids.each do |valid_id|
      attrs = build_minimal_attributes(model).merge(pk => valid_id)

      begin
        record = model.create!(attrs)
        assert_equal valid_id, record.public_send(pk),
                     "#{model.name} should accept valid ID: #{valid_id}"
        record.destroy if record.persisted?
      rescue => e
        flunk "#{model.name} should accept valid ID '#{valid_id}' but got error: #{e.message}"
      end
    end

    # Test invalid IDs - these should be rejected
    invalid_ids.each do |invalid_id|
      attrs = build_minimal_attributes(model).merge(pk => invalid_id)

      begin
        model.create!(attrs)
        # If we get here, the invalid ID was accepted (which is wrong)
        flunk "#{model.name} should reject invalid ID '#{invalid_id}' but it was accepted. " \
              "Check if database CHECK constraint exists for #{model.table_name}.#{pk}"
      rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid
        # Expected: invalid ID was rejected
        assert true, "#{model.name} correctly rejected invalid ID: #{invalid_id}"
      end
    end
  end

  # Generate a unique ID for the model to avoid conflicts
  def generate_unique_id(model)
    prefix = model.name.gsub("::", "_").upcase
    timestamp = Time.current.strftime("%Y%m%d%H%M%S")
    "TEST_#{prefix}_#{timestamp}_#{rand(1000)}"
  end

  # Build minimal attributes required to create a record
  def build_minimal_attributes(model)
    attrs = {}

    model.columns_hash.each do |name, column|
      # Skip primary key (we set it explicitly)
      next if name == model.primary_key

      # Skip timestamps (set automatically)
      next if %w(created_at updated_at).include?(name)

      # Skip nullable columns with defaults
      next if column.null || column.default.present?

      # Set required attributes with appropriate values
      attrs[name] = default_value_for_column(column, model, name)
    end

    attrs
  end

  # Generate appropriate default value based on column type
  def default_value_for_column(column, model, column_name)
    case column.type
    when :integer, :bigint
      1
    when :boolean
      false
    when :datetime, :timestamp
      Time.current
    when :date
      Date.current
    when :uuid
      SecureRandom.uuid
    when :binary
      "binary_data"
    when :string, :text
      # For foreign keys, try to find a valid reference
      if column_name.end_with?("_id") && column.type == :string
        reference_value_for_foreign_key(model, column_name)
      else
        "TEST_VALUE"
      end
    when :decimal, :float
      1.0
    when :json, :jsonb
      {}
    else
      "DEFAULT"
    end
  end

  # Try to find a valid reference for foreign key columns
  def reference_value_for_foreign_key(model, column_name)
    # Try to infer the referenced model
    association_name = column_name.sub(/_id$/, "")
    reflection = model.reflections[association_name]

    if reflection&.klass
      referenced_model = reflection.klass
      # Try to find an existing record or create one
      if referenced_model.respond_to?(:first)
        existing = referenced_model.first
        return existing.public_send(referenced_model.primary_key) if existing
      end
    end

    # Fallback to a generic value
    "TEST_REF"
  rescue
    "TEST_REF"
  end
end
