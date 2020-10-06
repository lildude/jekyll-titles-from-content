# frozen_string_literal: true

require "helper"

class TestJekyllTitlesFromContentFilters < JekyllUnitTest
  def setup
    @filters = JekyllTitlesFromContent::Filters.new(fixture_site)
  end

  def test_markdownifies
    assert_equal "<h1 id=\"test\">test</h1>\n", @filters.markdownify("# test")
  end

  def test_strips_html
    assert_equal "test", @filters.strip_html("<h1>test</h1>")
  end

  def test_normalizes_whitespace
    assert_equal "test test", @filters.normalize_whitespace("test    test")
  end
end