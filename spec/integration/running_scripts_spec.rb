require 'spec_helper'

describe 'Executing a gitsh script' do
  context 'passed as a command line argument' do
    it 'runs the script and exits' do
      in_a_temporary_directory do
        write_file('myscript.gitsh', "init\ncommit")

        expect("#{gitsh} --git #{fake_git} myscript.gitsh").to execute.
          successfully.
          with_output_matching(/^Fake git: init\nFake git: commit\n$/)
      end
    end

    it 'exits with a useful error when the script does not exist' do
      in_a_temporary_directory do
        expect("#{gitsh} nosuchscript.gitsh").to execute.
          with_exit_status(66).
          with_error_output_matching(/^gitsh: Error: No such file or directory - nosuchscript\.gitsh\n$/)
      end
    end
  end

  context 'piped to standard input' do
    it 'runs the script and exits' do
      in_a_temporary_directory do
        write_file('myscript.gitsh', "init\ncommit")

        expect("cat myscript.gitsh | #{gitsh} --git #{fake_git}").to execute.
          successfully.
          with_output_matching(/^Fake git: init\nFake git: commit\n$/)
      end
    end
  end

  def gitsh
    File.expand_path('../../../bin/gitsh', __FILE__)
  end

  def fake_git
    File.expand_path('../../fixtures/fake_git', __FILE__)
  end
end
