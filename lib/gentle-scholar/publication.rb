# Author::       Soumya Ray (mailto: soumya.ray@gmail.com)
# License::      MIT

require 'typhoeus'
require 'nokogiri'
require 'date'

# This class loads a single publication from Google scholar and returns
# all its attributes, including dynamic attributes like number of citations
module GentleScholar
  class Publication
    GSCHOLAR_HOST_URL = 'http://scholar.google.com'
    GSCHOLAR_CIT_URL =
        'http://scholar.google.com/citations?view_op=view_citation&hl=en'

    SCAN_STR = {
      gscholar_url:
        "//div[contains(@class,'g-section cit-dgb')]/div/table/tr/td/a",
      cites: "//div[contains(@id,'scholar_sec')]/div/a",
      cites_url: "//div[contains(@id,'scholar_sec')]/div/a",
      title: '//div[@id="title"]/a',
      article_url: '//div[@id="title"]/a',
      chart_url: '//div[contains(@class,"cit-dd")]/img'
    }

    TABLE_ATTR = {
      authors: 'Authors',
      date: 'Publication date',
      journal: 'Journal name',
      volume: 'Volume',
      issue: 'Issue',
      pages: 'Pages',
      publisher: 'Publisher',
      description: 'Description'
    }

    def self.get_from_http(scholar_pub_id)
      auth_id, pub_id = scholar_pub_id.split(/:/)
      url = GSCHOLAR_CIT_URL + '&user=' + auth_id \
                             + '&citation_for_view=' + auth_id + ':' + pub_id
      res = Typhoeus::Request.new(url).run
      doc = Nokogiri::HTML(res.response_body)

      extract_html_elements(doc).merge(extract_html_table(doc))
    end

    def self.extract_html_elements(doc)
      xpath = {}
      elements = {}
      SCAN_STR.each do |elem, _path|
        xpath[elem] = doc.xpath(SCAN_STR[elem])
        elements[elem] = ''
      end

      elements[:cites] = xpath[:cites].text[/\d+/].to_i
      elements[:cites_url] = xpath[:cites_url][0].attributes['href'].value

      elements[:title] = xpath[:title].text
      elements[:article_url] = xpath[:article_url].attr('href').value

      elements[:chart_url] = xpath[:chart_url].attr('src').value

      elements[:gscholar_url] = GSCHOLAR_HOST_URL \
                                + xpath[:gscholar_url].attr('href').value

      elements
    end

    def self.extract_html_table(doc)
      # lambda gets text from right html column given name in left column
      table_pick = lambda do |name|
        doc.xpath("//div[starts-with(.,'#{name}')]")[0].children[1].text
      end

      elements = Hash[ TABLE_ATTR.map { |k, v| [k, table_pick.call(v)] } ]

      elements[:authors] = elements[:authors].split(/,/)\
                                             .map { |a| a.split(' ') }
      elements[:date] = Date.strptime(elements[:date], '%Y/%m/%d')
      elements
    end
  end
end
