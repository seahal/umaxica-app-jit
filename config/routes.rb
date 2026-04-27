# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # #FIXME remove or exile this
  # CSP violation reporting endpoint (host-agnostic, all domains)
  post "/csp-violation-report", to: "csp_violations#create"

  # BFF
  draw :apex
  # sign in / up
  draw :sign
  # Jump Page
  draw :jump
end
