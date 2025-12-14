require "test_helper"

class AppTimelineAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = AppTimelineAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
