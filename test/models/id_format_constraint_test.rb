# frozen_string_literal: true

require "test_helper"

class IdFormatConstraintTest < ActiveSupport::TestCase
  def setup
    Rails.application.eager_load!
    @models = ActiveRecord::Base.descendants
      .reject(&:abstract_class?)
      .select { |model| model.name&.match?(/(Status|Event|Level|Category)\z/) }
      .select { |model| model.type_for_attribute(model.primary_key).type == :string }
  end

  test "string id format constraints allow only A-Z0-9_ for status/event/level/category models" do
    assert_predicate @models, :any?, "対象モデルが見つかりませんでした"

    @models.each do |model|
      valid_id = "A_#{model.name.upcase}"
      invalid_id = "bad-id"

      attributes = build_required_attributes(model).merge(model.primary_key => valid_id)
      record = model.create!(attributes)
      assert_equal valid_id, record.public_send(model.primary_key), "#{model.name} should allow valid id"

      assert_raises(
        ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid,
        "#{model.name} should reject invalid id",
      ) do
        model.create!(build_required_attributes(model).merge(model.primary_key => invalid_id))
      end
    end
  end

  private

  def build_required_attributes(model)
    model.columns_hash.each_with_object({}) do |(name, column), attrs|
      next if name == model.primary_key
      next if %w(created_at updated_at).include?(name)
      next if column.null || !column.default.nil?

      attrs[name] = fallback_value(column)
    end
  end

  def fallback_value(column)
    case column.type
    when :integer
      1
    when :boolean
      true
    when :datetime
      Time.current
    when :date
      Date.current
    when :uuid
      SecureRandom.uuid
    when :binary
      "x"
    else
      "VALUE"
    end
  end
end
