require "test_helper"

class EmailConsumerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  def setup
    @consumer = EmailConsumer.new
    ActionMailer::Base.deliveries.clear
  end
end
