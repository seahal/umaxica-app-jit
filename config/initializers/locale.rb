# frozen_string_literal: true

require "i18n/backend/fallbacks"

# Allow english requests to transparently reuse japanese strings until proper
# translations are added.
I18n::Backend::Simple.include I18n::Backend::Fallbacks

region_code = ENV.fetch("REGION_CODE") # REGION_CODE is required, no default value
locale_root = Rails.root.join("config/locales")
region_dir = locale_root.join(region_code)

unless region_dir.directory?
  raise "REGION_CODE='#{region_code}' is invalid. Directory not found: #{region_dir}. " \
        "Valid values are: #{locale_root.children.filter_map { |child| child.basename if child.directory? }.join(", ")}"
end

config_locale_files = Dir[locale_root.join("**", "*.{rb,yml}")]
region_locale_files = Dir[region_dir.join("**", "*.{rb,yml}")]

I18n.load_path -= config_locale_files
I18n.load_path += region_locale_files
I18n.load_path.uniq!

I18n.load_path += Rails.root.glob("lib/locale/*.{rb,yml}")
I18n.available_locales = [:en, :ja]
I18n.default_locale = :ja
I18n.fallbacks = { en: [:en, :ja], ja: [:ja, :en] }
