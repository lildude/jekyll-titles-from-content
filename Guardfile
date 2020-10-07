# frozen_string_literal: true

guard :minitest do
  watch(%r!^test/(.*)\/?test_(.*)\.rb$!)
  watch(%r!^lib/(.*/)?([^/]+)\.rb$!) { |m| "test/test_#{m[2]}.rb" }
  watch(%r!^test/helper\.rb$!) { "test" }
  watch(%r!^lib/jekyll-titles-from-content.rb$!) { "test" }
end
