require "test_helper"

class OrgContactStatusTest < ActiveSupport::TestCase
  include ContactStatusModelTestHelper

  setup do
    @model_class = OrgContactStatus
    @valid_id = "ACTIVE".freeze
    @subject = @model_class.new(title: @valid_id)
  end
end
