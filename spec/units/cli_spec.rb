require 'spec_helper'
require 'gitsh/cli'

describe Gitsh::CLI do
  describe '#run' do
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
end
