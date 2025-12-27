# frozen_string_literal: true

require 'committee'
require 'committee/test/methods'

class TestClass
  include Committee::Test::Methods

  def committee_options
    {
      schema: Committee::Drivers.load_from_file('public/openapi.yml'),
      prefix: "/v1",
    }
  end

  def request
    Object.new
  end

  def response
    Object.new
  end

  def inspect_validator
    puts "Validator class: #{schema_validator.class}"
    puts "Validator methods: #{schema_validator.public_methods(false)}"
  end
end

TestClass.new.inspect_validator
