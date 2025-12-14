require "test_helper"

class AppDocumentAuditEventTest < ActiveSupport::TestCase
  include StatusModelTestHelper

  setup do
    @model_class = AppDocumentAuditEvent
    @valid_id = "UPLOADED".freeze
    @subject = @model_class.new(id: @valid_id)
  end
end
