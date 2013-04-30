Gem::Specification.new do |s|
  s.name        = 'deriving_license'
  s.version     = '0.1.4'
  s.summary     = "Deriving Licence finds the license agreements for all gems in your Gemfile"
  s.description = "Deriving Licence finds the license agreements for all gems in your Gemfile if included in your project, or in a Gemfile passed to the included binary"
  s.authors     = ["Tom Allen"]
  s.email       = 'tom@jugglethis.net'
  s.homepage    = 'http://www.github.com/Schwolop/deriving_license'
  s.executables << 'deriving_license'
  s.license     = 'beerware'
  
  s.require_paths = ["lib"]
  s.files         = `git ls-files`.split($\)
  s.test_files    = s.files.grep(/^test\//)
  
  s.add_runtime_dependency "gemnasium-parser"
  s.add_runtime_dependency "safe_yaml"
end