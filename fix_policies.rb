# typed: false
# frozen_string_literal: true

require 'fileutils'

def fix_file(path)
  content = File.read(path)
  new_content =
    content.gsub(/\b(\w+Policy(::Scope)?)\.new\((.*)\)/) do |match|
      policy_class = $1
      args_str = $3

      # Split by the first comma that is not inside parentheses
      # But since these are simple, a simple split might work, let's be a bit more careful

      parts = []
      current_part = ""
      paren_depth = 0
      args_str.each_char do |c|
        if c == ',' && paren_depth == 0
          parts << current_part
          current_part = ""
        else
          paren_depth += 1 if c == '('
          paren_depth -= 1 if c == ')'
          current_part << c
        end
      end
      parts << current_part

      if parts.size == 2
        user_arg = parts[0].strip
        record_arg = parts[1].strip
        "#{policy_class}.new(#{record_arg}, user: #{user_arg})"
      else
        match # Don't change if not exactly 2 arguments
      end
    end

  return unless new_content != content

  File.write(path, new_content)
  puts "Updated #{path}"

end

if ARGV.empty?
  Dir.glob('test/policies/*_test.rb').each { |f| fix_file(f) }
else
  ARGV.each { |f| fix_file(f) }
end
