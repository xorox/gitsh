require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  describe '#run' do
    context 'with a TTY and no script file' do
      it 'starts an interactive runner' do
        runner = stub('runner', run: nil)
        runner_factory = stub('InteractiveRunner', new: runner)
        cli = described_class.new(
          args: [],
          interactive_runner_factory: runner_factory
        )

        cli.run

        expect(runner).to have_received(:run)
      end
    end

    context 'with a script file argument' do
      it 'starts a script runner for the script file' do
        file_path = File.expand_path('../../fixtures/script', __FILE__)
        runner = stub('runner', run: nil)
        runner_factory = stub('ScriptRunner', new: runner)
        cli = described_class.new(
          args: [file_path],
          script_runner_factory: runner_factory
        )

        cli.run

        expect(runner_factory).to have_received(:new).
          with(has_entry(script: responds_with(:path, file_path)))
        expect(runner).to have_received(:run)
      end
    end

    context 'without a TTY' do
      it 'starts a script runner for standard input' do
        runner = stub('runner', run: nil)
        runner_factory = stub('ScriptRunner', new: runner)
        env = stub('env', input_stream: stub('stdin', tty?: false), :[] => nil)
        cli = described_class.new(
          args: [],
          script_runner_factory: runner_factory,
          env: env
        )

        cli.run

        expect(runner_factory).to have_received(:new).
          with(has_entry(script: env.input_stream))
        expect(runner).to have_received(:run)
      end
    end
  end
end
