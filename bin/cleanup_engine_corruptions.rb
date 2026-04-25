#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# bin/cleanup_engine_corruptions.rb
# Reverses accidental prefixing of non-route constructs during Rails engine shift.

TARGET_DIRS = %w[app engines lib test db config].freeze
EXTENSIONS = %w[.rb .erb .yml .md].freeze

# Prefixes to remove if they are NOT route helpers
ENGINES = {
  'identity' => 'sign_',
  'distributor' => 'post_',
  'foundation' => 'base_',
  'zenith' => 'acme_'
}.freeze

def cleanup_file(path)
  content = File.read(path)
  original_content = content.dup

  ENGINES.each do |engine, prefix|
    # Regex explanation:
    # Look for engine name + dot + prefix.
    # We want to replace "identity.sign_foo" with "sign_prefix_foo"
    # but ONLY if it is not a route helper (doesn't end in _path or _url).
    
    # This matches: identity.sign_something
    # We use a negative lookahead to ensure it's not followed by something that ends in _path or _url
    # Rust-flavored regex doesn't support lookarounds in the grep tool, but Ruby does!
    
    pattern = /(?<![a-zA-Z0-9_])#{engine}\.(#{prefix}[a-z0-9_]+)(?!\b(?:path|url|route|proxy|mapping|helper))/i
    
    content.gsub!(pattern) do |match|
      suffix = $1
      # Check again if suffix ends with path/url just in case
      if suffix.end_with?('_path', '_url', '_route', '_proxy', '_mapping', '_helper')
        match # keep it
      else
        puts "  [#{engine}] Replacing '#{match}' with '#{suffix}' in #{path}"
        suffix
      end
    end
    
    # Also handle corrupted @instance variables like @foundation.base_seconds
    content.gsub!(/@#{engine}\.(#{prefix}[a-z0-9_]+)/i) do |match|
      suffix = $1
      puts "  [#{engine}] Replacing instance var '#{match}' with '@#{suffix}' in #{path}"
      "@#{suffix}"
    end
    
    # Handle corrupted strings inside test files or I18n keys
    # e.g. "distributor.post_id" -> "post_id"
    # e.g. t("...identity.sign_in") -> t("...sign_in")
    # This is trickier because we don't want to break "identity.sign_app_root_path" strings.
    # But usually route helpers in strings don't have the engine prefix unless they are absolute.
  end

  if content != original_content
    File.write(path, content)
    true
  else
    false
  end
rescue => e
  puts "Error processing #{path}: #{e.message}"
  false
end

puts "Starting engine corruption cleanup..."

count = 0
changed = 0

TARGET_DIRS.each do |dir|
  next unless Dir.exist?(dir)
  
  Dir.glob(File.join(dir, '**', "*{#{EXTENSIONS.join(',')}}")).each do |path|
    next if File.directory?(path)
    count += 1
    changed += 1 if cleanup_file(path)
  end
end

puts "Finished. Processed #{count} files, updated #{changed} files."
