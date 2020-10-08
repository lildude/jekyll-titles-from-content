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

    def truncate(string, count, cont = "")
      spl = string.split
      tr = spl.first(count).join(" ")
      tr += cont if spl.length > count
      tr
    end

    def title_for(document)
      return document.data["title"] if title?(document)

      first_line = document.content.split("\n").find { |l| l unless strip_markup(l).empty? }
      return truncate(strip_markup(first_line), count, dotdotdot) unless first_line.nil?

      document.data["title"] # If we can't produce a title, we use the inferred one.
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
    #
    # This is a terribly slow hack as we're reading the YAML for every document, but I can't find
    # a better way of doing this as I can't find a method of obtaining the original unprocessed
    # frontmatter.
    def inferred_title?(document)
      return false unless document.is_a?(Jekyll::Document)

      meta = read_yaml(File.dirname(document.path), File.basename(document.path))
      !meta.key?("title")
    end

    def filters
      @filters ||= JekyllTitlesFromContent::Filters.new(site)
    end

    # This is a slightly modified version of Jekyll::Convertible.read_yaml
    def read_yaml(base, name)
      filename = File.join(base, name)

      begin
        content = File.read(filename)
        if content =~ Jekyll::Document::YAML_FRONT_MATTER_REGEXP
          content = $POSTMATCH # rubocop:disable Lint/UselessAssignment
          data = SafeYAML.load(Regexp.last_match(1))
        end
      rescue SyntaxError => e
        Jekyll.logger.warn "YAML Exception reading #{filename}: #{e.message}"
        raise e if site.config["strict_front_matter"]
      rescue StandardError => e
        Jekyll.logger.warn "Error reading file #{filename}: #{e.message}"
        raise e if site.config["strict_front_matter"]
      end

      data || {}
    end
  end
end
