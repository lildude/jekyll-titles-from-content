# frozen_string_literal: true

module JekyllTitlesFromContent
  class Filters
    include Jekyll::Filters
    include Liquid::StandardFilters

    def initialize(site)
      @site    = site
      @context = JekyllTitlesFromContent::Context.new(site)
    end
  end
end
