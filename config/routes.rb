# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # Four-engine deployment architecture:
  # - signature: Auth/Passkey/OIDC endpoints (sign.* hosts)
  # - world: Global BFF/Dashboard (apex hosts)
  # - station: Regional operations (www.* hosts)
  # - press: Content delivery via closed network (docs/news/help)

  # Signature engine - Authentication and authorization
  if Jit::Deployment.signature?
    mount Jit::Signature::Engine => "/"
  end

  # World engine - Global BFF and dashboard
  if Jit::Deployment.world?
    mount Jit::World::Engine => "/"
  end

  # Station engine - Regional operations
  if Jit::Deployment.station?
    mount Jit::Station::Engine => "/"
  end

  # Press engine - Content delivery
  if Jit::Deployment.press?
    mount Jit::Press::Engine => "/"
  end
end
