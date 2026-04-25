# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # Four-engine deployment architecture:
  # - identity: Auth/Passkey/OIDC endpoints (sign.* hosts)
  # - zenith: Global BFF/Dashboard (acme hosts)
  # - foundation: Regional operations (base.* hosts)
  # - distributor: Content delivery (post.* hosts)

  # Identity engine - Authentication and authorization
  if Jit::Deployment.identity?
    mount Jit::Identity::Engine => "/", :as => :identity
  end

  # Zenith engine - Global BFF and dashboard
  if Jit::Deployment.zenith?
    mount Jit::Zenith::Engine => "/", :as => :zenith
  end

  # Foundation engine - Regional operations
  if Jit::Deployment.foundation?
    mount Jit::Foundation::Engine => "/", :as => :foundation
  end

  # Distributor engine - Content delivery
  if Jit::Deployment.distributor?
    mount Jit::Distributor::Engine => "/", :as => :distributor
  end
end
