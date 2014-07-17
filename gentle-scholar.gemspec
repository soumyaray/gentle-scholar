$:.push File.expand_path("../lib", __FILE__)
require 'gentle-scholar/version'

Gem::Specification.new do |s|
  s.name        =  'gentle-scholar'
  s.version     =  GentleScholar::VERSION
  s.date        =  GentleScholar::DATE
  s.summary     =  'Google Scholar infor extractor'
  s.description =  'Extract author/paper info from Google Scholar'
  s.authors     =  ['Soumya Ray']
  s.email       =  'soumya.ray@gmail.com'
  s.files       =  `git ls-files`.split("\n")
  s.test_files  =  `git ls-files -- {test,spec,features}/*`.split("\n")
  s.homepage    =  'https://github.com/soumyaray/gentle-scholar'
  s.license     =  'MIT'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-rg'
  s.add_runtime_dependency 'nokogiri', '>= 1.6.2'
  s.add_runtime_dependency 'typhoeus', '>= 0.6.8'
end
