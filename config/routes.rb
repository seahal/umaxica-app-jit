# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # #FIXME remove or exile this
  # CSP violation reporting endpoint (host-agnostic, all domains)
  post "/csp-violation-report", to: "csp_violations#create"

  # Global
  # BFF
  draw :apex
  # sign in / up
  draw :sign
  # regional
  ## back end of edge endpoints
  draw :core
  # endpoints for docs + help + news
  draw :docs
end
