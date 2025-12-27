# frozen_string_literal: true

namespace :license do
  desc "Run license_finder with only Bundler and NPM package managers"
  task check: :environment do
    sh "bundle exec license_finder --enabled-package-managers bundler npm"
  end

  desc "Generate license report"
  task report: :environment do
    sh "bundle exec license_finder report --enabled-package-managers bundler npm"
  end

  desc "Generate license report in CSV format"
  task csv: :environment do
    sh "bundle exec license_finder report --format csv --enabled-package-managers bundler npm > licenses.csv"
  end
end
