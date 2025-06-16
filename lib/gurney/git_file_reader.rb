module Gurney
  class GitFileReader

    def initialize(git, branch, read_from_git:, prefix: '.')
      @git = git
      @branch = branch
      @read_from_git = read_from_git
      @prefix = prefix
    end

    def read(filename)
      prefixed_filename = File.join(@prefix, filename)
      if @read_from_git
        begin
          @git.show("#{@branch}:#{prefixed_filename}")
        rescue Git::GitExecuteError
          # happens if branch does not exist
        end
      else
        File.read(prefixed_filename) if File.exist?(prefixed_filename)
      end
    end

  end
end
