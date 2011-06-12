# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-forum-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-forum-extension"
  s.version     = RadiantForumExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["William Ross"]
  s.email       = ["radiant@spanner.org"]
  s.homepage    = "radiant.spanner.org"
  s.summary     = %q{Forum and Comment Extension for Radiant CMS}
  s.description = %q{Nice clean forums and page comments for inclusion in your radiant site. Derived very long ago from beast. Requires the reader extension.}

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]

  s.post_install_message = %{
  Add this to your radiant project with:

    config.gem 'radiant-forum-extension', :version => '~> #{RadiantForumExtension::VERSION}'

  }

  s.add_dependency 'radiant-reader-extension', "~> 2.0.0.rc1"
end