require 'readline'
require 'optparse'
require 'gitsh/environment'
require 'gitsh/interactive_runner'
require 'gitsh/interpreter'
require 'gitsh/script_runner'
require 'gitsh/version'

module Gitsh
  class CLI
    EX_OK = 0
    EX_USAGE = 64
    EX_NOINPUT = 66

    def initialize(opts={})
      interpreter_factory = opts.fetch(:interpreter_factory, Interpreter)

      @env = opts.fetch(:env, Environment.new)
      @interpreter = interpreter_factory.new(@env)
      @readline = opts.fetch(:readline, Readline)
      @unparsed_args = opts.fetch(:args, ARGV).clone
      @interactive_runner_factory = opts.fetch(
        :interactive_runner_factory,
        InteractiveRunner
      )
      @script_runner_factory = opts.fetch(:script_runner_factory, ScriptRunner)
    end

    def run
      parse_arguments
      if unparsed_args.any?
        exit_with_usage_message
      elsif script_file
        run_script_file
      elsif env.input_stream.tty?
        run_interactive
      else
        run_stdin
      end
    end

    private

    attr_reader :env, :readline, :unparsed_args, :interpreter,
      :interactive_runner_factory, :script_runner_factory, :script_file

    def run_interactive
      interactive_runner_factory.new(
        readline: readline,
        env: env,
        interpreter: interpreter
      ).run
    end

    def run_script_file
      File.open(script_file, 'r') { |file| run_script(file) }
    rescue Errno::ENOENT
      env.puts_error "gitsh: Error: No such file or directory - #{script_file}"
      exit EX_NOINPUT
    rescue Errno::EACCES
      env.puts_error "gitsh: Error: Permission denied - #{script_file}"
      exit EX_NOINPUT
    end

    def run_stdin
      run_script(env.input_stream)
    end

    def run_script(script)
      script_runner_factory.new(script: script, interpreter: interpreter).run
    end

    def exit_with_usage_message
      env.puts_error option_parser.banner
      exit EX_USAGE
    end

    def parse_arguments
      option_parser.parse!(unparsed_args)
      @script_file = unparsed_args.pop
    rescue OptionParser::InvalidOption => err
      unparsed_args.concat(err.args)
    end

    def option_parser
      OptionParser.new do |opts|
        opts.banner = 'usage: gitsh [--version] [-h | --help] [--git PATH]'

        opts.on('--git [COMMAND]', 'Use the specified git command') do |git_command|
          env.git_command = git_command
        end

        opts.on_tail('--version', 'Display the version and exit') do
          env.puts VERSION
          exit EX_OK
        end

        opts.on_tail('--help', '-h', 'Display this help message and exit') do
          env.puts opts
          exit EX_OK
        end
      end
    end
  end
end
