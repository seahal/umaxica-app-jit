ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Setup JWT keys for testing if not present
if ENV["JWT_PRIVATE_KEY"].blank?
  key = OpenSSL::PKey::EC.generate("prime256v1")
  ENV["JWT_PRIVATE_KEY"] = Base64.strict_encode64(key.to_der)
  ENV["JWT_PUBLIC_KEY"] = Base64.strict_encode64(key.public_to_der)
end

Rails.root.glob("test/support/**/*.rb").each { |f| require f }

require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
