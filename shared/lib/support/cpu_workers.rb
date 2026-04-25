# typed: false
# frozen_string_literal: true

require "etc"
require "open3"
require "rbconfig"

# Prefer physical cores for Rails test parallelism, and fall back safely when
# the host does not expose a reliable physical-core count.
module TestSupport
  module CpuWorkers
    module_function

    def detect(env: ENV, host_os: RbConfig::CONFIG["host_os"], capture: method(:capture_command))
      requested_workers = positive_integer(env["PARALLEL_WORKERS"])
      return requested_workers if requested_workers

      workers =
        if linux?(host_os)
          linux_physical_cores(capture)
        elsif mac_or_bsd?(host_os)
          mac_or_bsd_physical_cores(capture)
        end

      positive_integer(workers) || positive_integer(Etc.nprocessors) || 1
    rescue StandardError
      1
    end

    def linux?(host_os)
      host_os.to_s.downcase.include?("linux")
    end

    def mac_or_bsd?(host_os)
      normalized = host_os.to_s.downcase
      normalized.include?("darwin") || normalized.include?("bsd") || normalized.include?("dragonfly")
    end

    def linux_physical_cores(capture)
      output = capture.call("lscpu")
      return unless output

      cores_per_socket = lscpu_value(output, "Core(s) per socket")
      sockets = lscpu_value(output, "Socket(s)")
      return unless cores_per_socket && sockets

      cores_per_socket * sockets
    rescue StandardError
      nil
    end

    def mac_or_bsd_physical_cores(capture)
      physical_cores = positive_integer(capture.call("sysctl", "-n", "hw.physicalcpu"))
      return physical_cores if physical_cores

      positive_integer(capture.call("sysctl", "-n", "hw.physicalcpu_max"))
    rescue StandardError
      nil
    end

    def capture_command(*command)
      stdout, _stderr, status = Open3.capture3({ "LC_ALL" => "C" }, *command)
      stdout if status.success?
    rescue StandardError
      nil
    end

    def lscpu_value(output, label)
      output.to_s.each_line do |line|
        match = line.match(/\A#{Regexp.escape(label)}:\s*(\d+)\s*\z/)
        return Integer(match[1]) if match
      end
      nil
    end

    def positive_integer(value)
      number = Integer(value, exception: false)
      return unless number&.positive?

      number
    rescue StandardError
      nil
    end
  end
end
