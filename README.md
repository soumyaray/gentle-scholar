# gentle-scholar gem
[![Gem Version](https://badge.fury.io/rb/gentle-scholar.svg)](http://badge.fury.io/rb/gentle-scholar)
[![Build Status](https://travis-ci.org/soumyaray/gentle-scholar.svg?branch=v1.0.1)](https://travis-ci.org/soumyaray/gentle-scholar)

Gem to extract Google Scholar publication given URL of a publication

##About:
**NOTE:** This gem is not to to search or crawl through Google Scholar.
This also will not extract bibtex (please see the excellent
  [gscholar](https://rubygems.org/gems/gscholar) gem for that).

This gem is for publishing academics to extract their own publication
information from Google Scholar. It can retrieve standard citation information
(authors, journal, title, etc.). Additionally, it can retrieve number of
citations reported by Google Scholar, link to citations page, chart of
citations over time, and link to author's Google Scholar profile.

##Usage:

Given a google scholar article such as:

    http://scholar.google.com.tw/citations?view_op=view_citation&hl=en&user=6WjiSOwAAAAJ&citation_for_view=6WjiSOwAAAAJ:9yKSN-GCB0IC

Retrieve information by copying the author and article ID from the URL:

    sec_paper = GScholarPub.new('6WjiSOwAAAAJ:u5HHmVD_uO8C')

This returns:

    #<GScholarPub:0x007fb0bc18df70
      @article_url="http://pubsonline.informs.org/doi/abs/10.1287/isre.1100.0340",
      @authors=[["Soumya", "Ray"], ["Sung", "S", "Kim"], ["James", "G", "Morris"]],
      @chart_url="http://www.google.com/chart?chs=475x90&cht=bvs&chf=bg,s,e8f4f7&chco=1111cc&chbh=r,2.0,0.0&chxt=x,y&chxr=1,0,5,5&chd=t:100.0,80.0,100.0
      @cites=14,
      @cites_url="http://scholar.google.com/scholar?oi=bibs&hl=en&oe=ASCII&cites=11777343089817755068",
      @description="The highly competitive and rapidly changing market for online services is becoming increasingly effective at locking users in through
      @issue="1",
      @journal="Information Systems Research",
      @pages="197-213",
      @title="Research Note\u0097Online Users' Switching Costs: Their Nature and Formation",
      @volume="23"
    >
