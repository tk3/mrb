require 'thor'
require 'erb'
require 'fileutils'

module Mrb
  class CLI < Thor
    desc "get", "get mruby source code"
    def get()
      %x{git clone https://github.com/mruby/mruby.git}
    end

    desc "gem NAME", "create necessary files, directory constitution"
    def gem(name)
      if m = name.match(/^mruby-(.*)/)
        full_name = name
        name = m[1]
      else
        full_name = "mruby-#{name}"
        name = name
      end

      puts "Creating gem '#{full_name}'..."

      FileUtils.mkdir_p full_name
      File.write "#{full_name}/README.md", ERB.new(Mrb::Template::README).result(binding)
      File.write "#{full_name}/mrbgem.rake", ERB.new(Mrb::Template::MRBGEM_RAKE).result(binding)

      FileUtils.mkdir_p "#{full_name}/src"
      File.write "#{full_name}/src/example.c", ERB.new(Mrb::Template::SRC).result(binding)

      FileUtils.mkdir_p "#{full_name}/test"
      File.write "#{full_name}/test/example.c", ERB.new(Mrb::Template::TEST_C).result(binding)
      File.write "#{full_name}/test/example.rb", ERB.new(Mrb::Template::TEST_MRB).result(binding)
    end

    desc "version", "show version number"
    def version()
      puts Mrb::VERSION
    end
  end
end
