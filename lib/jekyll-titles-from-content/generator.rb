# frozen_string_literal: true

module JekyllTitlesFromContent
  class Generator < Jekyll::Generator
    attr_accessor :site

    CONVERTER_CLASS = Jekyll::Converters::Markdown
    STRIP_MARKUP_FILTERS = [:markdownify, :strip_html, :normalize_whitespace].freeze

    # Regex to strip extra markup still present after markdownify
    # (footnotes at the moment).
    EXTRA_MARKUP_REGEX = %r!\[\^[^\]]*\]!.freeze

    CONFIG_KEY = "titles_from_content"
    ENABLED_KEY = "enabled"
    WORDS_KEY = "words"
    COLLECTIONS_KEY = "collections"
    DOTDOTDOT_KEY = "dotdotdot"

    safe true
    priority :lowest

    def initialize(site)
      @site = site
    end

    def generate(site)
      @site = site
      return if disabled?

      Jekyll.logger.debug "Titles from content: Settings titles when there aren't any"
      documents = site.pages
      documents = site.pages + site.docs_to_write if collections?

      documents.each do |document|
        next unless should_add_title?(document)
        next if document.is_a?(Jekyll::StaticFile)

        document.data["title"] = title_for(document)
      end
    end

    def should_add_title?(document)
      markdown?(document) && !title?(document)
    end

    def title?(document)
      !inferred_title?(document) && !document.data["title"].nil?
    end

    def markdown?(document)
      markdown_converter.matches(document.extname)
    end

    def markdown_converter
      @markdown_converter ||= site.find_converter_instance(CONVERTER_CLASS)
    end

    def title_for(document)
      return document.data["title"] if title?(document)

      first_line = strip_markup(document.content.split("\n").first.to_s)
      split_line = first_line.split
      new_title = split_line.first(count).join(" ")
      new_title += dotdotdot if split_line.length > count
      return new_title if new_title

      document.data["title"] # If we cant match a title, we use the inferred one.
    rescue ArgumentError => e
      raise e unless e.to_s.start_with?("invalid byte sequence in UTF-8")
    end

    private

    def strip_markup(string)
      STRIP_MARKUP_FILTERS.reduce(string) do |memo, method|
        filters.public_send(method, memo)
      end.gsub(EXTRA_MARKUP_REGEX, "")
    end

    def option(key)
      site.config[CONFIG_KEY] && site.config[CONFIG_KEY][key]
    end

    def disabled?
      option(ENABLED_KEY) == false
    end

    def collections?
      option(COLLECTIONS_KEY) == true
    end

    def dotdotdot
      option(DOTDOTDOT_KEY) || ""
    end

    def count
      option(WORDS_KEY) || 5
    end

    # Documents (posts and collection items) have their title inferred from the filename.
    # We want to override these titles, because they were not explicitly set.
    def inferred_title?(document)
      document.is_a?(Jekyll::Document)
    end

    def filters
      @filters ||= JekyllTitlesFromContent::Filters.new(site)
    end
  end
end
