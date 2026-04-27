# typed: false
# frozen_string_literal: true

require 'fileutils'

Dir.glob('app/policies/*.rb').each do |file_path|
  next if file_path == 'app/policies/application_policy.rb'

  content = File.read(file_path)
  lines = content.lines

  start_index = lines.find_index { |l| l.include?('class Scope < ApplicationPolicy::Scope') }

  if start_index
    indent = lines[start_index][/\A\s*/]
    end_index = nil

    ((start_index + 1)...lines.size).each do |i|
      if /\A#{indent}end\s*\z/.match?(lines[i])
        end_index = i
        break
      end
    end

    if end_index
      scope_block_lines = lines[start_index..end_index]

      # Extract resolve method logic
      # Only match uncommented def resolve
      resolve_start = scope_block_lines.find_index { |l| l =~ /^\s*def resolve/ }
      has_logic = false
      relation_logic_lines = []

      if resolve_start
        resolve_indent = scope_block_lines[resolve_start][/\A\s*/]
        resolve_end = nil
        ((resolve_start + 1)...scope_block_lines.size).each do |i|
          if /\A#{resolve_indent}end\s*\z/.match?(scope_block_lines[i])
            resolve_end = i
            break
          end
        end

        if resolve_end
          logic_lines = scope_block_lines[(resolve_start + 1)...resolve_end]
          logic = logic_lines.join.strip

          if logic != "scope.all" && !logic.empty?
            has_logic = true
            relation_logic_lines = logic_lines.map { |l| l.gsub(/\bscope\b/, 'relation') }
          end
        end
      end

      # Prepare replacement
      replacement = []
      if has_logic
        replacement << "#{indent}relation_scope do |relation|\n"
        relation_logic_lines.each do |line|
          replacement << line
        end
        replacement << "#{indent}end\n"
      end

      # Remove Pundit comments and Scope block
      # Find Pundit note
      pundit_note_start = lines.find_index { |l| l =~ /# NOTE: Up to Pundit v2.3.1/ }
      if pundit_note_start && pundit_note_start < start_index
        # Remove lines from pundit_note_start up to start_index-1
        # But we want to be careful not to remove important code if it was somehow in between.
        # In these files, it's usually just empty lines or comments.
        lines.slice!(pundit_note_start...start_index)
        # Adjust start and end indices
        diff = start_index - pundit_note_start
        start_index -= diff
        end_index -= diff
      end

      # Replace Scope block
      lines[start_index..end_index] = replacement

      new_content = lines.join
      # Clean up multiple newlines
      new_content.gsub!(/\n{3,}/, "\n\n")
      # Ensure ends with single newline
      new_content.strip!
      new_content << "\n"

      File.write(file_path, new_content)
      puts "Processed #{file_path}"
    else
      puts "Could not find end for Scope class in #{file_path}"
    end
  else
    puts "Skipped #{file_path} (no Scope class found)"
  end
end
