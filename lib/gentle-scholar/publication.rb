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

    attr_reader :title, :cites, :cites_url, :chart_url, :article_url
    attr_reader :authors, :date, :journal, :volume, :issue, :pages, :publisher
    attr_reader :description, :gscholar_url
    # TODO: @doc only for development, testing modes
    attr_reader :doc

    SCAN_STR = {
      gscholar_url:
        "//div[contains(@class,'g-section cit-dgb')]/div/table/tr/td/a",
      cites: "//div[contains(@id,'scholar_sec')]/div/a",
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

    def initialize(scholar_pub_id)
      auth_id, pub_id = scholar_pub_id.split(/:/)
      url = GSCHOLAR_CIT_URL + '&user=' + auth_id \
                             + '&citation_for_view=' + auth_id + ':' + pub_id
      res = Typhoeus::Request.new(url).run
      @doc = Nokogiri::HTML(res.response_body)

      extract_html_elements
      extract_html_table
    end

    def extract_html_elements
      @cites = @doc.xpath(SCAN_STR[:cites]).text[/\d+/].to_i
      @cites_url = @doc.xpath(SCAN_STR[:cites])[0].attributes['href'].value

      @title = @doc.xpath(SCAN_STR[:title]).text
      @article_url = @doc.xpath(SCAN_STR[:article_url]).attr('href').value

      @chart_url = @doc.xpath(SCAN_STR[:chart_url]).attr('src').value

      @gscholar_url = GSCHOLAR_HOST_URL + @doc.xpath(
                                    SCAN_STR[:gscholar_url]).attr('href').value
    end

    def extract_html_table
      # lambda gets text from right html column given name in left column
      table_pick = lambda do |name|
        @doc.xpath("//div[starts-with(.,'#{name}')]")[0].children[1].text
      end

      TABLE_ATTR.each do |k, v|
        instance_variable_set("@#{k}", table_pick.call(v))
      end

      @authors = @authors.split(/,/).map { |a| a.split(' ') }
      @date = Date.strptime(@date, '%Y/%m/%d')
    end
  end
end
