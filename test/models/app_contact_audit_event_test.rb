require "test_helper"

class AppContactAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = AppContactAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
