require './lib/gentle-scholar.rb'

SEC_PAPER = GentleScholar::Publication.new('6WjiSOwAAAAJ:u5HHmVD_uO8C')

## Load publication manually from irb/pry as follows:
# load 'lib/publication.rb'
# pub = GScholarPub.new('6WjiSOwAAAAJ:u5HHmVD_uO8C')
# (pub.methods - Object.methods).each do
#   |m| if m!=:doc then p m.to_s+': '+pub.send(m).to_s end
# end
