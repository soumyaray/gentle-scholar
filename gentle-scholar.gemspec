Gem::Specification.new do |s|
  s.name        =  'gentle-scholar'
  s.version     =  '1.0.2'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-rg'
  s.add_runtime_dependency 'nokogiri', '>= 1.6.2'
  s.add_runtime_dependency 'typhoeus', '>= 0.6.8'
  s.date        =  '2014-05-25'
  s.summary     =  'Google Scholar infor extractor'
  s.description =  'Extract author/paper info from Google Scholar'
  s.authors     =  ['Soumya Ray']
  s.email       =  'soumya.ray@gmail.com'
  s.files       =  ["lib/publication.rb"]
  s.homepage    =  'https://github.com/soumyaray/gentle-scholar'
  s.license     =  'MIT'
end
