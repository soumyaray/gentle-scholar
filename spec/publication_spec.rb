require 'minitest/autorun'
require 'minitest/rg'
require './minitest_helper.rb'

describe 'Publication', 'A single publication listing' do

  # let (:@sec_paper) do
  #   GScholarPub.new('6WjiSOwAAAAJ:u5HHmVD_uO8C')
  # end

  describe 'when it is a paper' do
    #
    # before do
    #   @sec_paper = GScholarPub.new('6WjiSOwAAAAJ:u5HHmVD_uO8C')
    # end

    before do
      @sec_paper = SEC_PAPER
    end

    it 'has the right title' do
      @sec_paper.title.must_equal 'Security Assurance: How Online Service '\
          'Providers Can Influence Security Control Perceptions and Gain Trust'
    end

    it 'has some number of cites' do
      @sec_paper.cites.must_be :>, 0
    end

    it 'has some url for listing cites' do
      @sec_paper.cites_url.must_match /http:\/\/.*/
    end

    it 'has some url for citations chart' do
      @sec_paper.chart_url.must_match /http:\/\/.*/
    end

    it 'has some url for the pulished article' do
      @sec_paper.article_url.must_match /http:\/\/.*/
    end

    it 'has the right author(s) (as nested array)' do
      @sec_paper.authors.must_equal [['Soumya', 'Ray'], ['Terence', 'Ow'], ['Sung', 'S', 'Kim']]
    end

    it 'has a publication date' do
      @sec_paper.date.must_be_instance_of Date
    end


    it 'has the right journal\'s name' do
      @sec_paper.journal.must_equal 'Decision Sciences'
    end

    it 'has the right volume number (as string)' do
      @sec_paper.volume.must_equal '42'
    end

    it 'has the right issue number (as string)' do
      @sec_paper.issue.must_equal '2'
    end

    it 'has the right page numbers' do
      @sec_paper.pages.must_equal '391-412'
    end

    it 'has the right publisher' do
      @sec_paper.publisher.must_equal 'Blackwell Publishing Inc'
    end

    it 'has some url for the main citations apage' do
      @sec_paper.gscholar_url.must_match /citations/
    end

  end

end
