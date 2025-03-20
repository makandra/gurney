module Gurney
  class GitFileReader

    def initialize(git, branch, read_from_git:)
      @git = git
      @branch = branch
      @read_from_git = read_from_git
    end

    def read(filename)
      if @read_from_git
        begin
          @git.show("#{@branch}:#{filename}")
        rescue Git::GitExecuteError
          # happens if branch does not exist
        end
      else
        File.read(filename) if File.exist?(filename)
      end
    end

  end
end
