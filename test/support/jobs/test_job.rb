# frozen_string_literal: true

class TestJob < ApplicationJob
  queue_as :default

  def perform(value)
    # Store the result in a class variable for testing
    self.class.last_performed_value = value
  end

  class << self
    attr_accessor :last_performed_value # rubocop:disable ThreadSafety/ClassAndModuleAttributes
  end
end
