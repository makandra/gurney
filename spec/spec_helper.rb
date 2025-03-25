require 'gurney'
require 'byebug'

module SpecHelper
  def silent
    expect{ yield }.to output(anything).to_stdout
  end

  def with_stdin(input)
    $stdin = StringIO.new
    $stdin.set_encoding(Encoding::ASCII) # Apparently what it is on the server
    $stdin.puts(input)
    $stdin.rewind
    yield
  ensure
    $stdin = STDIN
  end

end

Dir[File.join(__dir__, 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |conf|
  conf.include(SpecHelper)
end
