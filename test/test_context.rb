# frozen_string_literal: true

require "helper"

class TestJekyllTitlesFromContentContext < JekyllUnitTest
  def setup
    @ctx = JekyllTitlesFromContent::Context.new(fixture_site)
  end

  def test_returns_the_site
    assert_instance_of Jekyll::Site, @ctx.site
  end

  def test_returns_the_registers

    assert_kind_of Hash, @ctx.registers
    assert @ctx.registers[:site]
    assert_instance_of Jekyll::Site, @ctx.registers[:site]
  end
end