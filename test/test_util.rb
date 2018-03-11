require 'test/unit'
require "mrb/template"

class MrbTest < Test::Unit::TestCase
  def test_prefix
    actual = Mrb::Util.gen_names('mruby-aaa')
    assert_equal(actual[:name], 'aaa')
    assert_equal(actual[:full_name], 'mruby-aaa')
    assert_equal(actual[:internal_name], 'mruby_aaa')
  end

  def test_prefix_none
    actual = Mrb::Util.gen_names('aaa')
    assert_equal(actual[:name], 'aaa')
    assert_equal(actual[:full_name], 'mruby-aaa')
    assert_equal(actual[:internal_name], 'mruby_aaa')
  end
end
