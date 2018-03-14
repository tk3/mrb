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

  def test_git_clone_command
    actual = Mrb::Util.git_clone_command "https://example.com/",  "1.0.0", "path/to"
    assert_equal actual, "git clone --depth=1  -b 1.0.0  https://example.com/ path/to/1.0.0" 
  end

  def test_git_clone_command_master
    actual = Mrb::Util.git_clone_command "https://example.com/",  "master", "path/to"
    assert_equal actual, "git clone --depth=1  https://example.com/ path/to/master" 
  end
end
