# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # CSP violation reporting endpoint (host-agnostic, all domains)
  post "/csp-violation-report", to: "csp_violations#create"

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
end
