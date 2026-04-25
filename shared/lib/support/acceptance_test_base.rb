# typed: false
# frozen_string_literal: true

class AcceptanceTestBase < ActionDispatch::IntegrationTest
end

class FoundationAcceptanceTestBase < ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  def setup
    super
    host!(ENV.fetch("FOUNDATION_BASE_APP_URL", "base.app.localhost"))
    @routes = Rails.application.routes
  end
end

class DistributorAcceptanceTestBase < ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  def setup
    super
    host!(ENV.fetch("DISTRIBUTOR_POST_APP_URL", "post.app.localhost"))
    @routes = Rails.application.routes
  end
end

class ZenithAcceptanceTestBase < ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  def setup
    super
    host!(ENV.fetch("ZENITH_ACME_APP_URL", "acme.app.localhost"))
    @routes = Rails.application.routes
  end
end

class IdentityAcceptanceTestBase < ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  def setup
    super
    host!(ENV.fetch("IDENTITY_SIGN_APP_URL", "sign.app.localhost"))
    @routes = Rails.application.routes
  end
end
