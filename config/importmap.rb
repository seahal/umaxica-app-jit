# typed: false
# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "analytics_consent_gate", to: "analytics_consent_gate.js"
pin "theme_cookie", to: "theme_cookie.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
