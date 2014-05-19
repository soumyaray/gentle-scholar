Gem::Specification.new do |s|
  s.name        =  'gscholar'
  s.version     =  '0.2.0'
  s.add_runtime_dependency 'nokogiri', '>= 1.6.2'
  s.add_runtime_dependency 'typhoeus', '>= 0.6.8'
  s.date        =  '2013-05-18'
  s.summary     =  'Google Scholar scraper'
  s.description =  'Extract author/paper info from Google Scholar'
  s.authors     =  ['Soumya Ray']
  s.email       =  'soumya.ray@gmail.com'
  s.files       =  ["lib/gscholar.rb"]
  s.homepage    =  'https://github.com/soumyaray/gscholar'
  s.license     =  'MIT'
end
