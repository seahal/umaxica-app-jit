# typed: false
# frozen_string_literal: true

current_file = nil
files = {}
File.read('coverage/lcov.info').split('end_of_record').each do |record|
  if record =~ /^SF:(.*\.rb)/
    current_file = $1
    lf = record.match(/LF:(\d+)/)&.[](1)&.to_i || 0
    lh = record.match(/LH:(\d+)/)&.[](1)&.to_i || 0
    files[current_file] = { lf: lf, lh: lh, pct: (lf > 0) ? (100 * lh / lf) : 100 }
  end
end

files.select { |k, v| k.start_with?('./app/') && v[:pct] < 90 }
  .sort_by { |_k, v| v[:pct] }
  .first(50)
  .each { |k, v| puts "#{v[:pct]}% (#{v[:lh]}/#{v[:lf]}) #{k}" }
