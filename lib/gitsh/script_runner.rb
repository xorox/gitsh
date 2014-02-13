module Gitsh
  class ScriptRunner
    def initialize(opts)
      @script = opts.fetch(:script)
      @interpreter = opts.fetch(:interpreter)
    end

    def run
      script.each_line do |line|
        interpreter.execute(line)
      end
    end

    private

    attr_reader :script, :interpreter
  end
end
