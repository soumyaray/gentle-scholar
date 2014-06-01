# Author::       Soumya Ray (mailto: soumya.ray@gmail.com)
# License::      MIT
require 'typhoeus'
require 'nokogiri'
require 'date'

module GentleScholar
  # This class loads a single publication from Google scholar and returns
  # all its attributes, including dynamic attributes like number of citations
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

    SCAN_LAMBDAS = {
      cites:         ->(x) { x.text[/\d+/].to_i },
      cites_url:     ->(x) { x[0].attributes['href'].value },
      title:         ->(x) { x.text },
      article_url:   ->(x) { x.attr('href').value },
      chart_url:     ->(x) { x.attr('src').value },
      gscholar_url:  ->(x) { GSCHOLAR_HOST_URL + x.attr('href').value }
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

    TABLE_LAMBDAS = {
      authors:  ->(x) { x.split(/,/).map { |a| a.split(' ') } },
      date:     ->(x) { Date.strptime(x, '%Y/%m/%d') }
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
      xpath = Hash[SCAN_STR.map { |elem, path| [elem, doc.xpath(path)] }]
      Hash[SCAN_LAMBDAS.map { |key, lam| [key, lam.call(xpath[key])] }]
    end

    def self.extract_html_table(doc)
      # lambda gets text from right html column given name in left column
      table_extract = lambda do |name|
        doc.xpath("//div[starts-with(.,'#{name}')]")[0].children[1].text
      end

      elements = Hash[TABLE_ATTR.map { |k, v| [k, table_extract.call(v)] }]
      elements.merge(
        Hash[TABLE_LAMBDAS.map { |key, lam| [key, lam.call(elements[key])] }]
      )
    end
  end
end
