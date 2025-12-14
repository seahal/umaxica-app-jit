require "test_helper"

class ComContactStatusTest < ActiveSupport::TestCase
  include ContactStatusModelTestHelper

  setup do
    @model_class = ComContactStatus
    @valid_id = "ACTIVE".freeze
    @subject = @model_class.new(title: @valid_id)
  end
end
