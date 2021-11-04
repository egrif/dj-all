lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'version'
Gem::Specification.new do |s|
  s.name      = 'dj-all'
  s.executables = ['dj-all']
  s.version   = DjAll::VERSION
  s.platform  = Gem::Platform::RUBY
  s.summary   = 'GH Dajoku Interrogator CLI'
  s.description = "Interrogatin' the dajokuspace"
  s.authors   = ['Greenhouse Software']
  s.email     = ['runfast@greenhouse.io']

  s.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/grnhse'

  s.homepage  = 'https://github.com/grnhse/dj-all'
  s.license   = 'MIT'
  s.files     = Dir.glob("{lib,bin}/**/*") # This includes all files under the lib directory recursively, so we don't have to add each one individually.
  s.require_path = 'lib'
end
