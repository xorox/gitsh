require 'spec_helper'

describe 'Running a gitsh script' do
  it 'runs the script and exits' do
    in_a_temporary_directory do
      write_file('myscript.gitsh', "init\ncommit --allow-empty -m First")

      expect("#{gitsh} myscript.gitsh").to execute.successfully

      expect("/usr/bin/env git log --oneline").to execute.
        successfully.
        with_output_matching(/^[a-z0-9]+ First\n$/)
    end
  end

  it 'exits with a useful error when the script does not exist' do
    in_a_temporary_directory do
      expect("#{gitsh} nosuchscript.gitsh").to execute.
        with_exit_status(66).
        with_error_output_matching(/^gitsh: Error: No such file or directory - nosuchscript\.gitsh\n$/)
    end
  end

  def gitsh
    File.expand_path('../../../bin/gitsh', __FILE__)
  end
end
