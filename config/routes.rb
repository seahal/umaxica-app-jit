# frozen_string_literal: true

Rails.application.routes.draw do
  # Routing design:
  # - HTML (Rails renders HTML): stays as-is (no edge/client prefix)
  # - Edge API (browser/React Router; Cookie auth): /edge/vN/*
  # - Client API (iOS/Android; Bearer auth): /client/vN/*
  #
  # NOTE: "v1/v2" expresses breaking-change generations, and is nested under
  # "edge/client" to avoid mixing versioning with client segmentation.
  #
  # Representative mapping (path only; behavior unchanged):
  # - /v1/csrf        -> /edge/v1/csrf
  # - /v1/preference  -> /edge/v1/preference
  # - /v1/posts       -> /edge/v1/posts
  # - /v1/health      -> /edge/v1/health
  #
  # global
  # top level pages
  draw :apex
  # sign in / up
  draw :sign
  # regional
  ## back end of edge endpoints
  draw :core
  # endpoints for help
  draw :help
  # endpoints for docs
  draw :docs
  # endpoints for news
  draw :news

  # mount Rswag::Ui::Engine => '/api-docs'
  # mount Rswag::Api::Engine => '/api-docs'

  # Global health endpoints for each API surface.
  # (Auth-free, always returns 200; intended for liveness checks.)
  namespace :edge do
    namespace :v1 do
      resource :health, only: :show
    end
  end

  namespace :client do
    namespace :v1 do
      resource :health, only: :show
    end
  end
end
