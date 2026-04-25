# typed: false
# frozen_string_literal: true

require "test_helper"

class ApplicationPushDeviceTest < ActionDispatch::IntegrationTest
  test "ApplicationPushDevice inherits from ActionPushNative::Device" do
    assert_equal ActionPushNative::Device, ApplicationPushDevice.superclass
  end

  test "device class can be referenced" do
    assert_kind_of Class, ApplicationPushDevice
    assert_operator ApplicationPushDevice, :<, ActionPushNative::Device
  end

  test "device has platform enum defined" do
    assert_respond_to ApplicationPushDevice, :platforms
  end
end
