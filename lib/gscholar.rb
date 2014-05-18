require 'typhoeus'
require 'nokogiri'

class GScholarPub
  GSCHOLAR_URL = "http://scholar.google.com/citations?view_op=view_citation&hl=en&user="

  attr_reader :title, :cites, :cites_url, :chart_url, :article_url
  attr_reader :authors, :journal, :volume, :issue, :pages, :description
  attr_reader :doc

  # example scholar_pub_id = 6WjiSOwAAAAJ:u5HHmVD_uO8C
  def initialize(scholar_pub_id)
    auth_id, pub_id = scholar_pub_id.split(/:/)
    url = GSCHOLAR_URL + auth_id+"&citation_for_view="+auth_id+":"+pub_id
    req = Typhoeus::Request.new(url)
    res = req.run

    # 1. the quick and dirty way of getting the number of cites
    # cites = res.response_body[/Cited by \d+/][/\d+/].to_i

    # 2. the longer but safer way to get items from a DOM structure
    @doc = Nokogiri::HTML(res.response_body)

    ## Cited-by HTML:
    # <div class="g-section" id="scholar_sec">
    #   <div class="cit-dt">Total citations</div>
    #   <div class="cit-dd">
    #     <a class="cit-dark-link" href="...">Cited by 15</a>
    #   </div>
    # </div>
    @cites = doc.xpath("//div[contains(@id,'scholar_sec')]/div/a"\
                      ).text[/\d+/].to_i
    @cites_url = doc.xpath("//div[contains(@id,'scholar_sec')]/div/a"\
                          )[0].attributes["href"].value

    # <div id="title">
    #   <a style="text-decoration:none" href="http://linktoarticle" >
    #      Paper Title
    #   </a>
    # </div>
    @title = doc.xpath("//div[@id=\"title\"]/a").text
    @article_url = doc.xpath("//div[@id=\"title\"]/a").attr("href").value

    # lambda function gets text from right column given name in left column
    table_pick = lambda do |name|
      doc.xpath("//div[starts-with(.,'#{name}')]")[0].children[1].text
    end

    # <div class="g-section">
    #   <div class="cit-dt">Authors</div>
    #   <div class="cit-dd"> First Author,  Second Author,  Third G Author</div>
    # </div>
    all_auth = table_pick.call('Authors')
    @authors = all_auth.split(/,/).map { |a| a.split(' ') }

    @journal = table_pick.call('Journal name')
    @volume = table_pick.call('Volume')
    @issue = table_pick.call('Issue')
    @pages = table_pick.call('Pages')
    @description = table_pick.call('Description')

    ## Chart HTML:
    # <div class="cit-dd">
    #   <img src="..." height="90" width="475" alt="">
    # </div>
    @chart_url = doc.xpath("//div[contains(@class,'cit-dd')]/img"\
                          ).attr("src").value

    #
    # @article_url = doc.xpath("//div[contains(@class, 'cit-dd')]"\
    #               "/a[contains(@class, 'cit-dark-link')]"\
    #               )[1].attributes["href"].value
  end

end

# load 'lib/gscholar.rb'
# pub = GScholarPub.new("6WjiSOwAAAAJ:u5HHmVD_uO8C")
# (pub.methods - Object.methods).each {|m| if m!=:doc then p m.to_s+": "+pub.send(m).to_s end}
