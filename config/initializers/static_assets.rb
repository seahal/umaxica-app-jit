# Serve dist/ directory as static assets
Rails.application.config.middleware.use(
  Rack::Static,
  urls: [ "/dist" ],
  root: Rails.root
)
