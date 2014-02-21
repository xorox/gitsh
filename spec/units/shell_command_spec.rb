require 'spec_helper'
require 'gitsh/shell_command'

describe Gitsh::ShellCommand do
  describe '#excute' do
    it 'spawns a process with the command and arguments' do
      Process.stubs(spawn: 1, wait: nil)
      env = stub('Environment',
        output_stream: stub(to_i: 1),
        error_stream: stub(to_i: 2)
      )
      command = described_class.new(env, 'echo', ['Hello world'])

      command.execute

      expect(Process).to have_received(:spawn).with(
        'echo', 'Hello world',
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
    end
  end
end
