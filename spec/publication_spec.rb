require 'minitest/autorun'
require 'minitest/rg'
require './spec/minitest_helper.rb'

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
      @sec_paper = SEC_RESULTS
    end

    it 'has the right title' do
      @sec_paper[:title].must_equal 'Security Assurance: How Online Service '\
          'Providers Can Influence Security Control Perceptions and Gain Trust'
    end

    it 'has some number of cites' do
      @sec_paper[:cites].must_be :>, 0
    end

    it 'has some url for listing cites' do
      @sec_paper[:cites_url].must_match %r{http://.*}
    end

    it 'should have citation trend information' do
      @sec_paper[:trend].must_be_kind_of Hash
      @sec_paper[:trend].size.must_be :>=, 4
      @sec_paper[:trend].map do |k, v|
        k.must_be_kind_of Symbol
        v.must_be_kind_of Numeric
      end
    end

    it 'has some url for the published article' do
      @sec_paper[:article_url].must_match %r{http://.*}
    end

    it 'has the right author(s) (as nested array)' do
      au_actual = [%w(Soumya Ray), %w(Terence Ow), %w(Sung S Kim)]
      @sec_paper[:authors].must_equal au_actual
    end

    it 'has a publication date' do
      @sec_paper[:date].must_be_instance_of Date
    end

    it 'has the right journal\'s name' do
      @sec_paper[:journal].must_equal 'Decision Sciences'
    end

    it 'has the right volume number (as string)' do
      @sec_paper[:volume].must_equal '42'
    end

    it 'has the right issue number (as string)' do
      @sec_paper[:issue].must_equal '2'
    end

    it 'has the right page numbers' do
      @sec_paper[:pages].must_equal '391-412'
    end

    it 'has the right publisher' do
      @sec_paper[:publisher].must_equal 'Blackwell Publishing Inc'
    end

    it 'has some url for the main citations apage' do
      @sec_paper[:gscholar_url].must_match(/citations/)
    end
  end

  describe 'when it is an unpublished paper (missing attributes)' do
    before do
      doc = GentleScholar::Publication.text_to_document(UNPUB_PAPER)
      @unpub_paper = GentleScholar::Publication.extract_from_document(doc)
    end

    it 'has the right basic information' do
      ti_actual = 'The Central Role of Engagement in Online Communities'
      @unpub_paper[:title].must_equal ti_actual
      @unpub_paper[:article_url].must_match(%r{http://.*})
      @unpub_paper[:gscholar_url].must_match(/citations/)
      au_actual = [%w(Soumya Ray), %w(Sung S Kim), %w(James G Morris)]
      @unpub_paper[:authors].must_equal au_actual
      @unpub_paper[:date].must_be_instance_of Date
      @unpub_paper[:journal].must_equal 'Information Systems Research'
      @unpub_paper[:publisher].must_equal 'INFORMS'
    end

    it 'must not produce error for non-existing information' do
      @unpub_paper[:volume].must_be_nil
      @unpub_paper[:issue].must_be_nil
      @unpub_paper[:pages].must_be_nil
      @unpub_paper[:chart_url].must_be_nil
    end
  end

end
