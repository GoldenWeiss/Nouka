# -*- encoding: utf-8 -*-
# stub: texplay 0.4.3 x86-mingw32 lib

Gem::Specification.new do |s|
  s.name = "texplay".freeze
  s.version = "0.4.3"
  s.platform = "x86-mingw32".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["John Mair (banisterfiend)".freeze]
  s.date = "2012-07-15"
  s.description = "TexPlay is a light-weight image manipulation framework for Ruby and Gosu".freeze
  s.email = ["jrmair@gmail.com".freeze]
  s.homepage = "http://banisterfiend.wordpress.com/2008/08/23/texplay-an-image-manipulation-tool-for-ruby-and-gosu/".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "TexPlay is a light-weight image manipulation framework for Ruby and Gosu".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gosu>.freeze, [">= 0.7.25"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 2.0.0"])
      s.add_development_dependency(%q<rake-compiler>.freeze, [">= 0.7.9"])
    else
      s.add_dependency(%q<gosu>.freeze, [">= 0.7.25"])
      s.add_dependency(%q<rspec>.freeze, [">= 2.0.0"])
      s.add_dependency(%q<rake-compiler>.freeze, [">= 0.7.9"])
    end
  else
    s.add_dependency(%q<gosu>.freeze, [">= 0.7.25"])
    s.add_dependency(%q<rspec>.freeze, [">= 2.0.0"])
    s.add_dependency(%q<rake-compiler>.freeze, [">= 0.7.9"])
  end
end
