# typed: false
# frozen_string_literal: true

require "i18n/backend/fallbacks"

# Allow english requests to transparently reuse japanese strings until proper
# translations are added.
I18n::Backend::Simple.include I18n::Backend::Fallbacks

region_code = ENV.fetch("REGION_CODE") # REGION_CODE is required, no default value
locale_root = Rails.root.join("config/locales")

# "all" is a virtual region that combines www + jpn (www takes priority over jpn).
# Other region codes map directly to a directory under config/locales/.
REGION_COMPOSE = { "all" => %w(jpn www) }.freeze
region_dirs =
  if REGION_COMPOSE.key?(region_code)
    REGION_COMPOSE[region_code].map { |code| locale_root.join(code) }
  else
    [locale_root.join(region_code)]
  end

region_dirs.each do |dir|
  next if dir.directory?

  raise "REGION_CODE='#{region_code}' is invalid. Directory not found: #{dir}. " \
        "Valid values are: #{locale_root.children.filter_map { |child|
          child.basename if child.directory?
        }.join(", ")}, all"
end

# Collect region locale files in priority order (later entries win in i18n)
region_locale_files = region_dirs.flat_map { |dir| Dir[dir.join("**", "*.{rb,yml}")] }

# Identify all region directories to exclude others
all_region_dirs = locale_root.children.select(&:directory?)
included_region_dirs = region_dirs.to_set
other_region_dirs = all_region_dirs.reject { |dir| included_region_dirs.include?(dir) }
other_region_files = other_region_dirs.flat_map { |dir| Dir[dir.join("**", "*.{rb,yml}")] }.map(&:to_s)

# Reject only files from other regions
I18n.load_path.reject! { |path| other_region_files.include?(path.to_s) }
I18n.load_path += region_locale_files
I18n.load_path.uniq!

I18n.load_path += Rails.root.glob("lib/locale/*.{rb,yml}")
I18n.available_locales = [:en, :ja]
I18n.default_locale = :ja
I18n.fallbacks = { en: [:en, :ja], ja: [:ja, :en] }
I18n.backend.reload!
