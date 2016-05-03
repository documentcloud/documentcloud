require 'test_helper'

class StatisticsTest < ActiveSupport::TestCase

  DAY_DATE    = Date.today - 1.day
  WEEK_DATE   = Date.today - 1.week - 2.day
  MONTH_DATE  = Date.today - 1.month - 2.day
  def test_daily_documents
    docs = DC::Statistics.daily_documents( MONTH_DATE )
    assert_equal 1, docs.detect{ |day, count| day.to_date == MONTH_DATE }.last
  end

  def test_daily_pages
    pgs = DC::Statistics.daily_pages( MONTH_DATE )
    assert_equal 68, pgs.detect{ |day, count| day.to_date == WEEK_DATE }.last
  end

  def test_weekly_documents
    docs = DC::Statistics.weekly_documents( Date.parse("2013-01-01") )
    assert_equal [1, 1], docs.values
  end

  def test_weekly_pages
    pgs = DC::Statistics.weekly_pages
    assert_equal [68, 68], pgs.values
  end

  def test_daily_hits_on_documents
    hits = DC::Statistics.daily_hits_on_documents
    assert_equal 18, hits[ DAY_DATE ]
  end

  def test_weekly_hits_on_documents
    hits = DC::Statistics.weekly_hits_on_documents
    assert_equal [122, 18], hits.values
  end

  def test_daily_hits_on_notes
    hits = DC::Statistics.daily_hits_on_notes
    assert_equal [11, 3].sort, hits.values.sort
  end

  def test_weekly_hits_on_notes
    hits = DC::Statistics.weekly_hits_on_notes
    assert_equal [3, 11].sort, hits.values.sort
  end

  def test_daily_hits_on_searches
    hits = DC::Statistics.daily_hits_on_searches
    assert_equal 1, hits[ Date.today - 1.week ]
  end

  def test_weekly_hits_on_searches
    hits = DC::Statistics.weekly_hits_on_searches
    assert_equal [1, 11, 13].sort, hits.values.sort
  end

  def test_pages_since
    assert_equal 68, DC::Statistics.pages_since( WEEK_DATE - 1.day )
  end

  def test_public_documents_per_account
    counts =  DC::Statistics.public_documents_per_account
    assert_equal 1, counts[ louis.id ]
  end

  def test_private_documents_per_account
    counts =  DC::Statistics.private_documents_per_account
    assert_equal 1, counts[ louis.id ]
  end

  def test_pages_per_account
    counts =  DC::Statistics.pages_per_account
    assert_equal 136, counts[ louis.id ]
  end

  def test_total_pages
    assert_equal 136, DC::Statistics.total_pages
  end

  def test_by_the_numbers
    nums = DC::Statistics.by_the_numbers
    assert_equal( {:total=>3,   :day=>3, :week=>3, :month=>3,  :half_year=>3}   , nums["All Organizations"] )
    assert_equal( {:total=>1,   :day=>1, :week=>1, :month=>1,  :half_year=>1}   , nums["Active Organizations"] )
    assert_equal( {:total=>4,   :day=>4, :week=>4, :month=>4,  :half_year=>4}   , nums["All Accounts"] )
    assert_equal( {:total=>1,   :day=>1, :week=>1, :month=>1,  :half_year=>1}   , nums["Active Accounts"] )
    assert_equal( {:total=>0,   :day=>0, :week=>0, :month=>0,  :half_year=>0}   , nums["Reviewers"] )
    assert_equal( {:total=>2,   :day=>0, :week=>0, :month=>1,  :half_year=>2}   , nums["Documents"] )
    assert_equal( {:total=>136, :day=>0, :week=>0, :month=>68, :half_year=>136} , nums["Pages"] )
    assert_equal( {:total=>2,   :day=>2, :week=>2, :month=>2,  :half_year=>2}   , nums["Notes"] )
  end

  def test_pages_per_minute
    assert_equal 0, DC::Statistics.pages_per_minute
  end

  def test_documents_by_access
    docs = DC::Statistics.documents_by_access
    assert_equal 1, docs[ Document::PRIVATE ]
    assert_equal 1, docs[ Document::PUBLIC  ]
  end

  def test_averate_page_count
    assert_equal 68, DC::Statistics.average_page_count
  end

  def test_average_entity_count
    assert_equal 1, DC::Statistics.average_entity_count
  end

  def test_embedded_document_count
    assert_equal 1, DC::Statistics.embedded_document_count
  end

  def test_remote_url_hits_last_week
    assert_equal 31, DC::Statistics.remote_url_hits_last_week
  end

  def test_remote_url_hits_all_time
    assert_equal 179, DC::Statistics.remote_url_hits_all_time
  end

  def test_count_organizations_embedding
    assert_equal 1, DC::Statistics.count_organizations_embedding
  end

  def test_count_total_collaborators
    assert_equal 0, DC::Statistics.count_total_collaborators
  end


end

