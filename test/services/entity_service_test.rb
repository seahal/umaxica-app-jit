# frozen_string_literal: true

require "test_helper"

class EntityServiceTest < ActiveSupport::TestCase
  test "EntityService class exists and can be referenced" do
    assert_equal EntityService, EntityService
  end

  test "EntityService can be instantiated" do
    service = EntityService.new

    assert_instance_of EntityService, service
  end

  test "EntityService responds to new" do
    assert_respond_to EntityService, :new
  end
end
