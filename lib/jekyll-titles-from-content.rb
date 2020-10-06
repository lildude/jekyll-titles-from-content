# frozen_string_literal: true

require "jekyll"
require "jekyll-titles-from-content/generator"

module JekyllTitlesFromContent
  autoload :Context, "jekyll-titles-from-content/context"
  autoload :Filters, "jekyll-titles-from-content/filters"
end
