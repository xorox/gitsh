require 'readline'
require 'optparse'
require 'gitsh/environment'
require 'gitsh/interactive_runner'
require 'gitsh/interpreter'
require 'gitsh/version'

module Gitsh
  class CLI
    EX_OK = 0
    EX_USAGE = 64

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
    end

    def run
      parse_arguments
      if unparsed_args.any?
        exit_with_usage_message
      else
        run_interactive
      end
    end

    private

    attr_reader :env, :readline, :unparsed_args, :interpreter,
      :interactive_runner_factory

    def run_interactive
      interactive_runner_factory.new(
        readline: readline,
        env: env,
        interpreter: interpreter
      ).run
    end

    def exit_with_usage_message
      env.puts_error option_parser.banner
      exit EX_USAGE
    end

    def parse_arguments
      option_parser.parse!(unparsed_args)
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
