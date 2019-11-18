require 'gurney'
require 'byebug'

module SpecHelper
  def silent
    expect{ yield }.to output(anything).to_stdout
  end

  def with_stdin(input)
    $stdin = StringIO.new
    $stdin.puts(input)
    $stdin.rewind
    yield
    $stdin = STDIN
  end

end

RSpec.configure do |conf|
  conf.include(SpecHelper)
end
