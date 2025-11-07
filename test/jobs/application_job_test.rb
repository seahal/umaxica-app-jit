# frozen_string_literal: true

require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  class TestJob < ApplicationJob
    def perform(value)
      value
    end
  end

  test "ApplicationJob is a subclass of ActiveJob::Base" do
    assert_kind_of ActiveJob::Base, ApplicationJob.new
  end

  test "jobs can be performed" do
    result = TestJob.new.perform("test_value")

    assert_equal "test_value", result
  end

  test "job class inherits from ApplicationJob" do
    assert_equal ApplicationJob, TestJob.superclass
  end

  test "job can be instantiated" do
    job = TestJob.new

    assert_instance_of TestJob, job
    assert_kind_of ApplicationJob, job
  end

  test "job class has queue adapter configured" do
    assert_not_nil TestJob.queue_adapter
  end
end
