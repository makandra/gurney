Gem::Specification.new do |s|
  s.name = 'gurney'
  s.authors = ['Martin Schaflitzl']
  s.files = Dir.glob("{bin,lib}/**/*")
  s.executables << 'gurney'
  s.summary = 'Gurney collects dependencies of a project and reports them to a web api.'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.add_runtime_dependency 'colorize', '~> 0.8'
  s.add_runtime_dependency 'httparty', '~> 0.17.1'
  s.add_runtime_dependency 'bundler', '~> 1.17'
  s.add_runtime_dependency 'git', '~> 1.5'
end
