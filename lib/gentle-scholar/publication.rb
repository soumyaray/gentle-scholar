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
      cites:         '//div[contains(@class,"gsc_value")]/div/a',  # scholar_sec
      cites_url:     '//div[contains(@class,"gsc_value")]/div/a',
      title:         '//div[@id="gsc_title"]/a',
      article_url:   '//div[@id="gsc_title"]/a',
      trend:         '//div[@id="gsc_graph"]',
      gscholar_url:  '//div[@id="gsc_lnv_ui"]/div/a'
      # gscholar_url:  "//div[contains(@class,'g-section cit-dgb')]"\
      #                        '/div/table/tr/td/a'
      #chart_url:     '//div[contains(@class,"cit-dd")]/img',
    }

    SCAN_LAMBDAS = {
      cites:         ->(x) { x.text[/\d+/].to_i },
      cites_url:     ->(x) { x[0].attributes['href'].value },
      title:         ->(x) { x.text },
      article_url:   ->(x) { x.attr('href').value },
      #chart_url:     ->(x) { x.attr('src').value },
      trend:         ->(graph) { extract_trend(graph) },

      gscholar_url:  ->(x) { GS_HOST_URL + x.attr('href').value }
    }

    TABLE_ATTR = {
      authors: 'Authors',
      date: 'Publication date',
      journal: 'Journal',
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

    def self.get_pub_http(scholar_pub_id)
      auth_id, pub_id = scholar_pub_id.split(/:/)
      url = GS_CIT_URL + '&user=' + auth_id \
                       + '&citation_for_view=' + auth_id + ':' + pub_id
      res = Typhoeus::Request.new(url).run
      Nokogiri::HTML(res.response_body)
    end

    def self.extract_from_http(scholar_pub_id)
      doc = get_pub_http(scholar_pub_id)
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
        extract = GentleScholar::Publication.extract_table_item(v, doc)
        extract ? [k, extract] : nil
      end

      elements = Hash[elements_a.compact].select { |_, v| v }

      puts elements.to_s
      puts '---'

      elements.merge(
        # Hash[TABLE_LAMBDAS.map { |key, lam| [key, lam.call(elements[key])] }]
        Hash[elements.map { |attr, extracted|
          if TABLE_LAMBDAS[attr]
            [attr, TABLE_LAMBDAS[attr].call(extracted)]
          else
            [attr, extracted]
          end
        }]
      )
    end

    def self.extract_table_item(name, doc)
      elem = doc.xpath("//div[@class='gs_scl' and contains(.,'#{name}')]")
      begin
        if elem.empty?
          return nil
        else
          elem.xpath('div[@class="gsc_value"]').text
        end
      rescue #e
        STDERR.puts "ERROR PROCESSING: #{name}"
        #raise e
      end
    end

    def self.extract_trend(doc)
      years = doc.xpath('//span[@class="gsc_g_t"]').children.map { |c| c.text }
      years_sym = years.map { |y| y.to_sym }
      count = doc.xpath('//span[@class="gsc_g_al"]').children.map { |c| c.text }
      count_i = count.map { |c| c.to_i }
      Hash[years_sym.zip(count_i)]
    end

    def self.http_to_file(scholar_pub_id = '6WjiSOwAAAAJ:u5HHmVD_uO8C', filename)
      doc = GentleScholar::Publication.get_pub_http(scholar_pub_id)
      File.open(filename, "w:#{doc.encoding}") { |f| f.write(doc) }
    end

    def self.file_to_document(filename = 'spec/docs/unpub_doc.txt')
      Nokogiri.parse(File.read(filename))
    end

    def self.extract_from_file(filename = 'spec/docs/unpub_doc.txt')
      doc = file_to_document(filename)
      extract_from_document doc
    end
  end
end
