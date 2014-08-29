# Author::       Soumya Ray (mailto: soumya.ray@gmail.com)
# License::      MIT
require 'typhoeus'
require 'nokogiri'
require 'date'

module GentleScholar
  # This class loads a single publication from Google scholar and returns
  # all its attributes, including dynamic attributes like number of citations
  class Publication
    GS_HOST_URL  = 'http://scholar.google.com'
    GS_CIT_URL   = "#{GS_HOST_URL}/citations?view_op=view_citation&hl=en"

    SCAN_STR = {
      gscholar_url:  "//div[contains(@class,'g-section cit-dgb')]"\
                                   '/div/table/tr/td/a',
      cites:         "//div[contains(@class,'gsc_value')]/div/a",  # scholar_sec
      cites_url:     "//div[contains(@class,'gsc_value')]/div/a",
      title:         '//div[@id="gsc_title"]/a',
      article_url:   '//div[@id="gsc_title"]/a',
      chart_url:     '//div[contains(@class,"cit-dd")]/img'
    }

    SCAN_LAMBDAS = {
      cites:         ->(x) { x.text[/\d+/].to_i },
      cites_url:     ->(x) { x[0].attributes['href'].value },
      title:         ->(x) { x.text },
      article_url:   ->(x) { x.attr('href').value },
      chart_url:     ->(x) { x.attr('src').value },
      gscholar_url:  ->(x) { GS_HOST_URL + x.attr('href').value }
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

    def self.get_html(scholar_pub_id)
      auth_id, pub_id = scholar_pub_id.split(/:/)
      url = GS_CIT_URL + '&user=' + auth_id \
                       + '&citation_for_view=' + auth_id + ':' + pub_id
      res = Typhoeus::Request.new(url).run
      doc = Nokogiri::HTML(res.response_body)
    end

    def self.get_from_http(scholar_pub_id)
      auth_id, pub_id = scholar_pub_id.split(/:/)
      url = GS_CIT_URL + '&user=' + auth_id \
                       + '&citation_for_view=' + auth_id + ':' + pub_id
      res = Typhoeus::Request.new(url).run
      doc = Nokogiri::HTML(res.response_body)

      extract_from_document(doc)
    end

    def self.extract_from_document(doc)
      extract_html_elements(doc).merge(extract_html_table(doc))
    end

    def self.extract_html_elements(doc)
      xpath = Hash[SCAN_STR.map { |elem, path| [elem, doc.xpath(path)] }]
      elements = SCAN_LAMBDAS.map do |key, lam|
        [key, lam.call(xpath[key])] if xpath[key].any?
      end

      Hash[elements.compact]
    end

    def self.extract_html_table(doc)
      elements_a = TABLE_ATTR.map do |k, v|
        extract = table_extract(v, doc)
        extract ? [k, extract] : nil
      end

      elements = Hash[elements_a.compact]

      elements.merge(
        Hash[TABLE_LAMBDAS.map { |key, lam| [key, lam.call(elements[key])] }]
      )
    end

    def self.table_extract(name, doc)
      elem = doc.xpath("//div[@class='gs_scl' and starts-with(.,'#{name}')]")
      #elem = doc.xpath("//div[starts-with(.,'#{name}')]")[0]
      begin
        elem.children[1].text if elem
      rescue
        puts "ERROR PROCESSING: #{name}"
      end
    end
  end
end
