require './lib/gentle-scholar.rb'
require 'nokogiri'

SEC_RESULTS = GentleScholar::Publication.get_from_http('6WjiSOwAAAAJ:u5HHmVD_uO8C')
UNPUB_PAPER = File.read('./spec/docs/unpub_doc.txt')
