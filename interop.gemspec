require_relative 'lib/interop/version'

Gem::Specification.new do |spec|
  spec.name          = 'interop'
  spec.version       = Hx::Interop::VERSION
  spec.authors       = ['Neil E. Pearson']
  spec.email         = ['neil@pearson.sydney']

  spec.summary       = 'Cross-language interop abstraction'
  spec.description   = 'Ruby implementation of hx/interop cross-language interop abstraction'
  spec.homepage      = 'https://github.com/hx/interop'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select { |f| f.match? %r{^lib/} }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
