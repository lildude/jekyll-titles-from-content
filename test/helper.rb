# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(__dir__, "..", "lib"))
$LOAD_PATH.unshift(__dir__)
require "simplecov"
SimpleCov.start do
  add_filter "/docs/"
  add_filter "/test/"
  add_filter "/vendor/"
end

require "jekyll"
require "jekyll-titles-from-content"
require "minitest/autorun"
require "minitest/color"

TEST_DIR     = __dir__
SOURCE_DIR   = File.expand_path("source", TEST_DIR)
DEST_DIR     = File.expand_path("destination", TEST_DIR)

Jekyll.logger.adjust_verbosity(:quiet => true)

class JekyllUnitTest < Minitest::Test
  include Jekyll

  def fixture_site(override = {})
    default_config = { "source" => SOURCE_DIR, "destination" => DEST_DIR }
    config = Jekyll::Utils.deep_merge_hashes(default_config, override)
    config = Jekyll.configuration(config)
    Jekyll::Site.new(config)
  end

  def page_by_path(site, path)
    site.pages.find { |p| p.path == path }
  end

  def doc_by_path(site, path)
    site.documents.find { |p| p.relative_path == path }
  end

end
