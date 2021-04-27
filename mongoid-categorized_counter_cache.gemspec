lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid/categorized_counter_cache/version'

Gem::Specification.new do |spec|
  spec.name          = 'mongoid-categorized_counter_cache'
  spec.version       = Mongoid::CategorizedCounterCache::VERSION
  spec.authors       = ['FENG Zhichao']
  spec.email         = ['flankerfc@gmail.com']

  spec.summary       = 'Mongoid Counter Cache extension: counter cache with categorized count'
  spec.description   = 'Mongoid Counter Cache extension: counter cache with categorized count'
  spec.homepage      = 'https://github.com/flanker/mongoid-categorized_counter_cache'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'mongoid', '~> 6.2'
  spec.add_runtime_dependency 'activemodel', '~> 5.1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'byebug', '~> 10.0.0'
end
