# frozen_string_literal: true

# Guard configuration for Jit::Application
# Usage: bundle exec guard

directories %w[app lib config test db].select { |d| Dir.exist?(d) }

guard :minitest, all_on_start: false do
  # Test files themselves
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/test_helper\.rb$}) { "test" }

  # Models -> Model tests
  watch(%r{^app/models/(.+)\.rb$}) { |m| "test/models/#{m[1]}_test.rb" }

  # Controllers -> Controller tests (mirrors multi-domain namespace structure)
  watch(%r{^app/controllers/(.+)_controller\.rb$}) { |m| "test/controllers/#{m[1]}_controller_test.rb" }

  # Controller concerns -> Concern tests
  watch(%r{^app/controllers/concerns/(.+)\.rb$}) { |m| "test/controllers/concerns/#{m[1]}_test.rb" }

  # Mailers -> Mailer tests
  watch(%r{^app/mailers/(.+)\.rb$}) { |m| "test/mailers/#{m[1]}_test.rb" }

  # Jobs -> Job tests
  watch(%r{^app/jobs/(.+)\.rb$}) { |m| "test/jobs/#{m[1]}_test.rb" }

  # Services -> Service tests
  watch(%r{^app/services/(.+)\.rb$}) { |m| "test/services/#{m[1]}_test.rb" }

  # Policies -> Policy tests
  watch(%r{^app/policies/(.+)\.rb$}) { |m| "test/policies/#{m[1]}_test.rb" }

  # Helpers -> Helper tests
  watch(%r{^app/helpers/(.+)\.rb$}) { |m| "test/helpers/#{m[1]}_test.rb" }

  # Forms -> Form tests
  watch(%r{^app/forms/(.+)\.rb$}) { |m| "test/forms/#{m[1]}_test.rb" }

  # Lib -> Lib tests
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/lib/#{m[1]}_test.rb" }

  # Config initializers -> Initializer tests
  watch(%r{^config/initializers/(.+)\.rb$}) { |m| "test/initializers/#{m[1]}_test.rb" }

  # Routes -> Integration tests
  watch(%r{^config/routes.*\.rb$}) { "test/integration" }

  # Fixtures -> rerun related model tests
  watch(%r{^test/fixtures/(.+)\.yml$}) { |m| "test/models/#{m[1].singularize}_test.rb" }
end

guard "livereload" do
  extensions = {
    css: :css,
    scss: :css,
    js: :js,
    html: :html,
    png: :png,
    gif: :gif,
    jpg: :jpg,
    jpeg: :jpeg
  }

  rails_view_exts = %w[erb haml slim]

  compiled_exts = extensions.values.uniq
  watch(%r{public/.+\.(#{compiled_exts * '|'})})

  extensions.each do |ext, type|
    watch(%r{
          (?:app|vendor)
          (?:/assets/\w+/(?<path>[^.]+)
           (?<ext>\.#{ext}))
          (?:\.\w+|$)
          }x) do |m|
      path = m[1]
      "/assets/#{path}.#{type}"
    end
  end

  watch(%r{app/views/.+\.(#{rails_view_exts * '|'})$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{config/locales/.+\.yml})
end
