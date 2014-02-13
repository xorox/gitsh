require 'spec_helper'
require 'stringio'
require 'gitsh/script_runner'

describe Gitsh::ScriptRunner do
  describe '#run' do
    it 'passes each line of the script to the interpreter' do
      script = StringIO.new("init\ncommit\n:exit\n")
      interpreter = stub('Interpreter', execute: nil)
      runner = described_class.new(script: script, interpreter: interpreter)

      runner.run

      expect(interpreter).to have_received(:execute).times(3)
      expect(interpreter).to have_received(:execute).with("init\n")
      expect(interpreter).to have_received(:execute).with("commit\n")
      expect(interpreter).to have_received(:execute).with(":exit\n")
    end
  end
end
