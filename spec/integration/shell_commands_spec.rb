require 'spec_helper'

describe 'Executing a shell command' do
  it 'accepts a command prefixed with a !' do
    GitshRunner.interactive do |gitsh|
      gitsh.type '!echo Hello world'
      expect(gitsh).to output_no_errors
      expect(gitsh).to output 'Hello world'
    end
  end
end
