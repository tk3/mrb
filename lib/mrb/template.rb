module Mrb
  class Template
    README = <<README_TEMPLATE
C Extension Example
=========

This is an example gem which implements a C extension.
README_TEMPLATE

    MRBGEM_RAKE = <<MRBGEM_RAKE_TEMPLATE
MRuby::Gem::Specification.new('<%= full_name %>') do |spec|
  spec.license = 'MIT'
  spec.author  = 'mruby developers'
  spec.summary = 'This is a template'
end
MRBGEM_RAKE_TEMPLATE

    SRC = <<SOURCE_TEMPLATE
#include <mruby.h>
#include <stdio.h>

static mrb_value
mrb_c_method(mrb_state *mrb, mrb_value self)
{
  puts("A C Extension");
  return self;
}

void
mrb_<%= name %>_gem_init(mrb_state* mrb) {
  struct RClass *class_<%= name %> = mrb_define_module(mrb, "<%= name.capitalize %>");
  mrb_define_class_method(mrb, class_<%= name %>, "c_method", mrb_c_method, MRB_ARGS_NONE());
}

void
mrb_<%= name %>_gem_final(mrb_state* mrb) {
  /* finalizer */
}
SOURCE_TEMPLATE

    TEST_C = <<TEST_C_TEMPLATE
#include <mruby.h>

void
mrb_<%= name %>_gem_test(mrb_state *mrb)
{
  /* test initializer in C */
}
TEST_C_TEMPLATE

    TEST_MRB = <<TEST_MRB_TEMPLATE
assert('C Extension Example') do
  <%= name.capitalize %>.respond_to? :c_method
end
TEST_MRB_TEMPLATE
  end
end
