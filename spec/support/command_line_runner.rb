require 'open3'

module Execution
  def execute
    Execution::Matcher.new
  end

  class Matcher
    def matches?(command)
      out, err, status = Open3.capture3(command)

      @command = command
      @actual_output = out
      @actual_error_output = err
      @actual_exit_status = status.exitstatus

      exit_status_matches? && output_matches? && error_output_matches?
    end

    def failure_message
      message = ["Command #{command.inspect}:"]
      unless exit_status_matches?
        message << " - Expected exit status #{expected_exit_status}, got #{actual_exit_status}"
      end
      unless output_matches?
        message << " - Expected output to match #{expected_output_pattern.inspect}, got #{actual_output.inspect}"
      end
      unless error_output_matches?
        message << " - Expected error output to match #{expected_error_output_pattern.inspect}, got #{actual_error_output.inspect}"
      end
      message.join("\n")
    end

    def successfully
      @expected_exit_status = 0
      @expected_error_output_pattern = /^$/
      self
    end

    def with_exit_status(status)
      @expected_exit_status = status
      self
    end

    def with_error_output_matching(pattern)
      @expected_error_output_pattern = pattern
      self
    end

    def with_output_matching(pattern)
      @expected_output_pattern = pattern
      self
    end

    private

    attr_reader :command, :expected_exit_status, :expected_error_output_pattern,
      :expected_output_pattern, :actual_exit_status, :actual_output,
      :actual_error_output

    def exit_status_matches?
      actual_exit_status == expected_exit_status
    end

    def output_matches?
      expected_output_pattern.nil? || actual_output =~ expected_output_pattern
    end

    def error_output_matches?
      expected_error_output_pattern.nil? ||
        actual_error_output =~ expected_error_output_pattern
    end
  end
end

RSpec.configure { |config| config.include Execution }
