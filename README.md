# gentle-scholar gem
[![Gem Version](https://badge.fury.io/rb/gentle-scholar.svg)](http://badge.fury.io/rb/gentle-scholar)
[![Build Status](https://travis-ci.org/soumyaray/gentle-scholar.svg?branch=v1.0.1)](https://travis-ci.org/soumyaray/gentle-scholar)

note: gentle-scholar tested to work on jruby-1.7.* even though Travis-CI reports build exec error

**Gem to extract Google Scholar publication given URL of a publication**

## About:
**NOTE:** This gem is not to to search or crawl through Google Scholar.
This also will not extract bibtex (please use
  [gscholar](https://rubygems.org/gems/gscholar) or similar gem for that).

This gem is to extract information on specific publications from Google Scholar.
It can retrieve standard citation information (authors, journal, title, etc.).
Additionally, it can retrieve number of citations reported by Google Scholar,
link to citations page, trend of citations over time, and link to author's
Google Scholar profile.

## Installation:

    $ gem install gentle-scholar

## Usage:

Given a google scholar article such as:

    http://scholar.google.com/citations?view_op=view_citation&hl=en&user=6WjiSOwAAAAJ&citation_for_view=6WjiSOwAAAAJ:9yKSN-GCB0IC

Retrieve information by copying the author and article ID from the URL:

- Run from command line

    $ gentle-scholar 6WjiSOwAAAAJ:9yKSN-GCB0IC

- Call from Ruby code:

    pub = GentleScholar::Publication.extract_from_http('6WjiSOwAAAAJ:9yKSN-GCB0IC')

This returns:

    => {:cites=>16,
     :cites_url=>"http://scholar.google.com/scholar?oi=bibs&hl=en&oe=ASCII&cites=11777343089817755068&as_sdt=5",
     :title=>"Research Note\u0097Online Users' Switching Costs: Their Nature and Formation",
     :article_url=>"http://pubsonline.informs.org/doi/abs/10.1287/isre.1100.0340",
     :trend=>{:"2012"=>4, :"2013"=>3, :"2014"=>9},
     :gscholar_url=>"http://scholar.google.com/citations?user=6WjiSOwAAAAJ&hl=en&oe=ASCII",
     :authors=>[["Soumya", "Ray"], ["Sung", "S", "Kim"], ["James", "G", "Morris"]],
     :date=>#<Date: 2012-03-01 ((2455988j,0s,0n),+0s,2299161j)>,
     :journal=>"Information Systems Research",
     :volume=>"23",
     :issue=>"1",
     :pages=>"197-213",
     :publisher=>"INFORMS",
     :description=>
      "The highly competitive and rapidly changing market for online services is becoming increasingly effective at locking users in through the coercive effects of switching costs. Although the information systems field increasingly recognizes that switching costs plays a big part in enforcing loyalty, little is known about what factors users regard as switching costs or why they perceive these costs. Consequently, it is hard for online services to know what lock-in strategies to use and when to apply them. We address this problem by first  ..."}
