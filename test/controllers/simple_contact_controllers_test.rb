# typed: false
# frozen_string_literal: true

require "test_helper"

class SimpleContactControllersTest < ActiveSupport::TestCase
  CONFIGS = [
    {
      klass: Core::App::Contact::EmailsController,
      model: AppContact,
      found_message: "Service contact email new pending for contact 42",
      created_message: "Service contact email create pending for contact 42",
    },
    {
      klass: Core::App::Contact::TelephonesController,
      model: AppContact,
      found_message: "Service contact telephone new pending for contact 42",
      created_message: "Service contact telephone create pending for contact 42",
    },
    {
      klass: Core::Org::Contact::EmailsController,
      model: OrgContact,
      found_message: "Org contact email new pending for contact 42",
      created_message: "Org contact email create pending for contact 42",
    },
    {
      klass: Core::Org::Contact::TelephonesController,
      model: OrgContact,
      found_message: "Org contact telephone new pending for contact 42",
      created_message: "Org contact telephone create pending for contact 42",
    },
  ].freeze

  CONFIGS.each do |config|
    test "#{config[:klass].name} validates contact lookup and renders placeholder content" do
      controller = build_controller(config[:klass], {})
      controller.send(:set_contact)

      assert_equal(
        { plain: "Contact ID is required", status: :bad_request },
        controller.instance_variable_get(:@_test_rendered),
      )

      controller = build_controller(config[:klass], contact_id: "missing")
      config[:model].stub(:find_by, nil) do
        controller.send(:set_contact)
      end

      assert_equal(
        { plain: "Contact not found", status: :not_found },
        controller.instance_variable_get(:@_test_rendered),
      )

      controller = build_controller(config[:klass], contact_id: "contact-1")
      contact = Struct.new(:id).new(42)
      config[:model].stub(:find_by, contact) do
        controller.send(:set_contact)
        controller.new

        assert_equal({ plain: config[:found_message] }, controller.instance_variable_get(:@_test_rendered))
        controller.create
      end

      assert_equal(
        { plain: config[:created_message], status: :created },
        controller.instance_variable_get(:@_test_rendered),
      )
    end
  end

  private

  def build_controller(klass, params_hash)
    controller = klass.new
    controller.define_singleton_method(:params) { @params_ref }
    controller.instance_variable_set(:@params_ref, params_hash.with_indifferent_access)
    controller.define_singleton_method(:render) { |**kwargs| @_test_rendered = kwargs }
    controller
  end
end
