
require 'fileutils'

def process_file(path)
  content = File.read(path)
  original_content = content.dup

  # Namespaces
  content.gsub!(/module Sign\b/, 'module Auth')
  content.gsub!(/module Back\b/, 'module Base')
  content.gsub!(/module Apex\b/, 'module Peak')
  content.gsub!(/class Sign\b/, 'class Auth')
  content.gsub!(/class Back\b/, 'class Base')
  content.gsub!(/class Apex\b/, 'class Peak')
  
  # Constants/Inheritance
  content.gsub!(/Sign::/, 'Auth::')
  content.gsub!(/Back::/, 'Base::')
  content.gsub!(/Apex::/, 'Peak::')

  # Routes and Helpers
  # sign_app_, sign_org_, sign_com_
  ['app', 'org', 'com'].each do |scope|
    content.gsub!("sign_#{scope}_", "auth_#{scope}_")
    content.gsub!("back_#{scope}_", "base_#{scope}_")
    content.gsub!("apex_#{scope}_", "peak_#{scope}_")
  end

  # Just :sign, :back, :apex symbols
  content.gsub!(/:sign\b/, ':auth')
  content.gsub!(/:back\b/, ':base')
  content.gsub!(/:apex\b/, ':peak')

  # Strings (paths, translations)
  # Fix paths in require and renders
  ['sign', 'back', 'apex'].each do |term|
    new_term = case term
               when 'sign' then 'auth'
               when 'back' then 'base'
               when 'apex' then 'peak'
               end
    content.gsub!("/#{term}/", "/#{new_term}/") 
    content.gsub!("'#{term}/", "'#{new_term}/")
    content.gsub!("\"#{term}/", "\"#{new_term}/")
  end

  # Translations
  content.gsub!('t("sign.', 't("auth.')
  content.gsub!('t("back.', 't("base.')
  content.gsub!('t("apex.', 't("peak.')
  content.gsub!("t('sign.", "t('auth.")
  content.gsub!("t('back.", "t('base.")
  content.gsub!("t('apex.", "t('peak.")
  
  # Loose translation keys
  content.gsub!(/t\s+'sign\./, 't \'auth.')
  content.gsub!(/t\s+"sign\./, 't "auth.')
  content.gsub!(/t\s+'back\./, 't \'base.')
  content.gsub!(/t\s+"back\./, 't "base.')
  content.gsub!(/t\s+'apex\./, 't \'peak.')
  content.gsub!(/t\s+"apex\./, 't "peak.')


  if content != original_content
    File.write(path, content)
    puts "Updated: #{path}"
  end
end

paths = [
  'test/integration/auth',
  'test/integration/peak_preference_regions_flow_test.rb'
]

files = []
paths.each do |p|
  if File.directory?(p)
    files += Dir.glob("#{p}/**/*")
  elsif File.file?(p)
    files << p
  end
end
files.select! { |f| File.file?(f) }

files.each do |file|
  process_file(file)
end
