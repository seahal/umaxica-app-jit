require "test_helper"

class OrgTimelineAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = OrgTimelineAuditEvent
    @valid_id = "CREATED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
