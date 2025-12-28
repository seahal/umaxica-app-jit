# frozen_string_literal: true

class EdgeHomeLinkComponent < ViewComponent::Base
  def initialize(text:, env_key:, dev_test_url:, class_name:)
    super()
    @text = text
    @env_key = env_key
    @dev_test_url = dev_test_url
    @class_name = class_name
  end

  def call
    link_to @text, resolved_url, class: @class_name
  end

  private

  def resolved_url
    env_value = ENV[@env_key].to_s
    return @dev_test_url if env_value.empty? && (Rails.env.local?)

    return @dev_test_url if env_value.empty?
    return env_value if env_value.start_with?("http://", "https://")

    "https://#{env_value}"
  end
end
