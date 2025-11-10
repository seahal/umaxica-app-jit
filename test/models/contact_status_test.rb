require "test_helper"


class ContactStatusModelsTest < ActiveSupport::TestCase
  STATUS_MODELS = {
    AppContactStatus => "app_status",
    ComContactStatus => "com_status",
    OrgContactStatus => "org_status"
  }.freeze

  test "contact status base is abstract with title primary key" do
    assert ContactStatus.abstract_class?
    assert_equal "title", ContactStatus.primary_key
  end

  STATUS_MODELS.each do |model, prefix|
    test "#{model.name} inherits from GuestsRecord" do
      assert_operator model, :<, GuestsRecord
    end

    test "#{model.name} persists and finds records by title" do
      title = "#{prefix}_#{SecureRandom.hex(4)}"
      created = model.create!(title: title)
      found = model.find(title)

      assert_equal title, created.title
      assert_equal created.title, found.title
    end

    test "#{model.name} enforces unique titles" do
      title = "#{prefix}_unique_#{SecureRandom.hex(4)}"
      model.create!(title: title)

      assert_raises(ActiveRecord::RecordNotUnique) do
        model.create!(title: title)
      end
    end

    # rubocop:disable Minitest/MultipleAssertions
    test "#{model.name} records timestamps" do
      status = model.create!(title: "#{prefix}_ts_#{SecureRandom.hex(4)}")

      assert_respond_to status, :created_at
      assert_respond_to status, :updated_at
      assert_not_nil status.created_at
      assert_not_nil status.updated_at
    end
    # rubocop:enable Minitest/MultipleAssertions
  end
end
