require "test_helper"

class ComTimelineAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = ComTimelineAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
