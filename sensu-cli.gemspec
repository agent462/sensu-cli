Gem::Specification.new do |s|
  s.name        = 'sensu-cli'
  s.version     = '0.0.1'
  s.platform    = Gem::Platform::RUBY
  s.date        = '2013-03-30'
  s.summary     = "A command line utility for Sensu."
  s.description = "A command line utility for interacting with the Sensu api."
  s.authors     = ["Bryan Brandau"]
  s.email       = 'agent462@gmail.com'
  s.has_rdoc    = false

  s.homepage    ='http://github.com/agent462/sensu-cli'
  s.add_dependency('rainbow', '1.1.4')
  s.add_dependency('trollop', '2.0')
  s.add_dependency('json', '1.7.7')

  s.files         = Dir.glob('{bin,lib}/**/*') + %w[sensu-cli.gemspec README.md settings.example.json]
  s.executables   = Dir.glob('bin/**/*').map { |file| File.basename(file) }
  s.require_paths = ['lib']
end
