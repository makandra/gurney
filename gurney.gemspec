lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gurney/version"

Gem::Specification.new do |spec|
  spec.name          = "gurney"
  spec.version       = Gurney::VERSION
  spec.authors       = ["Martin Schaflitzl"]
  spec.email         = ["martin.schaflitzl@makandra.de"]

  spec.summary       = 'Gurney is a small tool to extract yarn and RubyGems dependencies from project files and report them to a web api.'
  spec.homepage      = "https://github.com/makandra/gurney"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n").reject { |f| f.match(%r{^(test|spec|features|bin)/}) }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'colorize', '~> 0.8'
  spec.add_runtime_dependency 'httparty', '~> 0.17.1'
  spec.add_runtime_dependency 'bundler', '< 3'
  spec.add_runtime_dependency 'git', '~> 1.5'
end
