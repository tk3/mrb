require 'test/unit'
require "mrb"

class MrbTest < Test::Unit::TestCase
  def test_version
    refute_nil  Mrb::VERSION
  end
end
