# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rapidftr_addon_cpims/version'

Gem::Specification.new do |gem|
  gem.name          = "rapidftr_addon_cpims"
  gem.version       = RapidftrAddonCpims::VERSION
  gem.authors       = ["Faris Mohammed"]
  gem.email         = ["farismosman@gmail.com"]
  gem.description   = %q{RapidFTR addon for exporting files to CPIMS}
  gem.summary       = %q{RapidFTR addon for exporting files to CPIMS}
  gem.homepage      = "https://github.com/farismosman/rapidftr-addon-cpims"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "writeexcel"
  gem.add_dependency "activesupport"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "factory_girl",     '~> 2.6'
  gem.add_development_dependency "rake"
end
