require 'typhoeus'
require 'nokogiri'
require 'date'

class GScholarPub
  GSCHOLAR_HOST_URL = 'http://scholar.google.com'
  GSCHOLAR_CIT_URL = 
      'http://scholar.google.com/citations?view_op=view_citation&hl=en'

  attr_reader :title, :cites, :cites_url, :chart_url, :article_url,
               :authors, :date, :journal, :volume, :issue, :pages, :publisher,
               :description, :gscholar_url
  # TODO: @doc only for development, testing modes
  attr_reader :doc

  # example scholar_pub_id = 6WjiSOwAAAAJ:u5HHmVD_uO8C
  def initialize(scholar_pub_id)
    auth_id, pub_id = scholar_pub_id.split(/:/)
    url = GSCHOLAR_CIT_URL + '&user=' + auth_id \
                           + '&citation_for_view='+auth_id+':'+pub_id
    res = Typhoeus::Request.new(url).run

    # 1. the quick and dirty way of getting the number of cites
    # cites = res.response_body[/Cited by \d+/][/\d+/].to_i

    # 2. the longer but safer way to get items from a DOM structure
    @doc = Nokogiri::HTML(res.response_body)

    ## Cited-by HTML:
    # <div class="g-section" id="scholar_sec">
    #   <div class="cit-dt">Total citations</div>
    #   <div class="cit-dd">
    #     <a class="cit-dark-link" href="...">Cited by 15</a>
    @cites = doc.xpath("//div[contains(@id,'scholar_sec')]/div/a"\
                      ).text[/\d+/].to_i
    @cites_url = doc.xpath("//div[contains(@id,'scholar_sec')]/div/a"\
                          )[0].attributes["href"].value

    # <div id="title">
    #   <a style="text-decoration:none" href="http://linktoarticle" >
    #      Paper Title
    @title = doc.xpath('//div[@id="title"]/a').text
    @article_url = doc.xpath('//div[@id="title"]/a').attr('href').value

    # lambda function gets text from right column given name in left column
    table_pick = lambda do |name|
      doc.xpath("//div[starts-with(.,'#{name}')]")[0].children[1].text
    end

    # <div class="g-section">
    #   <div class="cit-dt">Authors</div>
    #   <div class="cit-dd"> First Author,  Second Author,  Third G Author</div>
    @authors = table_pick.call('Authors').split(/,/).map { |a| a.split(' ') }
    @date = Date.strptime(table_pick.call('Publication date'), '%Y/%m/%d')
    @journal = table_pick.call('Journal name')
    @volume = table_pick.call('Volume')
    @issue = table_pick.call('Issue')
    @pages = table_pick.call('Pages')
    @publisher = table_pick.call('Publisher')
    @description = table_pick.call('Description')

    ## Chart HTML:
    # <div class="cit-dd">
    #   <img src="..." height="90" width="475" alt="">
    @chart_url = doc.xpath("//div[contains(@class,'cit-dd')]/img"
                          ).attr("src").value

    # TODO: capture scholar's main google-scholar page
    # <div class="g-section cit-dgb">
    #   <div style="padding:0.3em 0.6em;">
    #     <table style="width:100%">
    #       <tbody>
    #         <tr>
    #           <td>
    #             <a href="/citations?user=6WjiSOwAAAAJ&...">« Back to list</a>
    #             &nbsp;&nbsp;<...input buttons...>
    #           </td><td style="..."></td></tr></tbody></table></div></div>

    @gscholar_url = GSCHOLAR_HOST_URL + doc.xpath("//div[contains(@class,'g-section cit-dgb')]/div/table/tr/td/a").attr('href').value
  end

end
