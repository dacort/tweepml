# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{tweepml}
  s.version = "0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Damon P. Cortesi"]
  s.date = %q{2009-09-29}
  s.description = %q{TweepML is an XML format used to represent a list of Tweeps (Twitter users).}
  s.email = %q{d.lifehacker@gmail.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "lib/tweepml.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/dacort/tweepml}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TweepML is an XML format used to represent a list of Tweeps (Twitter users).}

  # if s.respond_to? :specification_version then
  #   current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
  #   s.specification_version = 2
  # 
  #   if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
  #     s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
  #     s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
  #   else
  #     s.add_dependency(%q<mime-types>, [">= 1.15"])
  #     s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  #   end
  # else
  #   s.add_dependency(%q<mime-types>, [">= 1.15"])
  #   s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  # end
end