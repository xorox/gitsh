require 'spec_helper'
require 'gitsh/interactive_runner'

describe Gitsh::InteractiveRunner do
  describe '#run' do
    it 'handles a SIGINT' do
      readline = stub('readline', {
        :'completion_append_character=' => nil,
        :'completion_proc=' => nil
      })
      readline.stubs(:readline).
        returns('a').
        then.raises(Interrupt).
        then.returns('b').
        then.raises(SystemExit)

      env = stub('Environment', print: nil, puts: nil, :[] => nil)
      interpreter = stub('interpreter', execute: nil)
      history = stub('history', load: nil, save: nil)
      prompter = stub('prompter', prompt: 'gitsh% ')

      cli = described_class.new(
        env: env,
        readline: readline,
        interpreter: interpreter,
        history: history,
        prompter: prompter
      )
      begin
        cli.run
      rescue SystemExit
      end

      expect(interpreter).to have_received(:execute).twice
      expect(interpreter).to have_received(:execute).with('a')
      expect(interpreter).to have_received(:execute).with('b')
      expect(env).to have_received(:puts).once
    end
  end
end
