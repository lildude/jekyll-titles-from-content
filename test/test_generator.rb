# frozen_string_literal: true

require "helper"

class TestJekyllTitlesFromContentGenerator < JekyllUnitTest
  def setup
    @site = fixture_site
    @site.reset
    @site.read
    @gen = JekyllTitlesFromContent::Generator.new(@site)
  end

  def test_saves_the_site
    assert_equal @site, @gen.site
  end

  def test_detects_page_has_a_title
    assert @gen.title?(page_by_path(@site, "page-with-title.md"))
  end

  def test_detects_page_has_no_title
    refute @gen.title?(page_by_path(@site, "page.md"))
  end

  def test_detects_page_is_markdown
    assert @gen.markdown?(page_by_path(@site, "page.md"))
  end

  def test_detects_page_is_not_markdown
    refute @gen.markdown?(page_by_path(@site, "html-page.html"))
  end

  def test_knows_the_markdown_converter
    assert_instance_of Jekyll::Converters::Markdown, @gen.markdown_converter
  end

  def test_truncates_text_based_on_opts
    str = "This string has a lot of words and is quite long"
    assert_equal "This string has", @gen.truncate(str, 3)
    assert_equal "This string has a lot", @gen.truncate(str, 5, "")
    assert_equal "This string has a lot of words...", @gen.truncate(str, 7, "...")
    assert_equal "This string has a lot of words and is quite long", @gen.truncate(str, 50, "")
  end

  def test_should_not_add_title_to_page_with_title
    refute @gen.should_add_title?(page_by_path(@site, "page-with-title.md"))
  end

  def test_should_not_add_title_to_html_pages
    refute @gen.should_add_title?(page_by_path(@site, "html-page.html"))
  end

  def test_should_not_add_title_to_pages_with_empty_titles
    refute @gen.should_add_title?(page_by_path(@site, "page-with-empty-title.md"))
  end

  def test_pulls_title_with_h1
    assert_equal "Just an H1", @gen.title_for(page_by_path(@site, "page.md"))
  end

  def test_pulls_title_with_setex_h1
    assert_equal "This is also an H1", @gen.title_for(page_by_path(@site, "page-with-setex-h1.md"))
  end

  def test_pulls_title_with_markdown_and_strips_markdown
    assert_equal "Bold in the first line", @gen.title_for(
      page_by_path(@site, "page-with-markdown-first-line.md")
    )
  end

  def test_pulls_title_with_emoji
    assert_equal "This 😄 is an emoji", @gen.title_for(page_by_path(@site, "page-with-emoji.md"))
  end

  def test_pulls_title_with_many_blank_lines_first
    assert_equal "Text after seven blank lines", @gen.title_for(
      page_by_path(@site, "page-with-many-empty-lines-first.md")
    )
  end

  def test_pulls_title_from_text_after_image_without_alt
    assert_equal "T’is the content after photo", @gen.title_for(
      page_by_path(@site, "page-with-no-alt-img-firstline.md")
    )
  end

  def test_pulls_title_from_image_alt_on_first_line
    skip "Coming soon"
    assert_equal "Photo Alt Goes here", @gen.title_for(
      page_by_path(@site, "page-with-alt-img-firstline.md")
    )
  end

  def test_limits_title_to_five_words_by_default
    assert_equal "This is a very very", @gen.title_for(
      page_by_path(@site, "page-with-long-first-line.md")
    )
  end

  def test_respects_yaml_title
    assert_equal "Page with title", @gen.title_for(page_by_path(@site, "page-with-title.md"))
  end
end

class TestJekyllTitlesFromContentGeneratorProcessedDefaultConfig < JekyllUnitTest
  def setup
    @site = fixture_site
    @site.process
  end

  def test_sets_title_for_pages
    assert_equal "Just an H1", page_by_path(@site, "page.md").data["title"]
  end

  def test_respects_document_auto_title_by_default
    assert_equal "Test", doc_by_path(@site, "_posts/2020-01-20-test.md").data["title"]
  end

  def test_respects_document_yaml_title
    assert_equal "Page with title", page_by_path(@site, "page-with-title.md").data["title"]
  end

  def test_does_not_error_on_pages_without_content
    assert_nil page_by_path(@site, "page-without-content.md").data["title"]
  end
end

class TestJekyllTitlesFromContentGeneratorProcessedCustomConfig < JekyllUnitTest
  def setup
    @config = {
      "titles_from_content" => {
        "collections" => true,
        "words"       => 3,
        "dotdotdot"   => "...",
      },
    }
    @site = fixture_site(@config)
    @site.process
  end

  def test_replaces_auto_title_on_documents
    title = doc_by_path(@site, "_posts/2020-01-20-test.md").data["title"]
    refute_equal "Test", title
    assert_equal "Plain text longer...", title
  end

  def test_does_not_append_dotdotdot_on_short_titles
    assert_equal "Just an H1", page_by_path(@site, "page.md").data["title"]
  end
end

class TestJekyllTitlesFromContentGeneratorProcessedEnabledDisabled < JekyllUnitTest
  def test_disabled
    config = { "titles_from_content" => { "enabled" => false } }
    site = fixture_site(config)
    site.process
    refute_equal "Just an H1", page_by_path(site, "page.md").data["title"]
  end

  def test_explicitly_enabled
    config = { "titles_from_content" => { "enabled" => true } }
    site = fixture_site(config)
    site.process
    assert_equal "Just an H1", page_by_path(site, "page.md").data["title"]
  end
end
