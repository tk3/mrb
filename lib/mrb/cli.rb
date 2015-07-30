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

      variables = {
        :full_name => full_name,
        :name => name,
      }

      FileUtils.mkdir_p full_name
      File.write "#{full_name}/README.md", Mrb::Template.render('gem/README.md.erb', variables)
      puts "  create #{full_name}/README.md"
      File.write "#{full_name}/mrbgem.rake", Mrb::Template.render('gem/mrbgem.rake.erb', variables)
      puts "  create #{full_name}/mrbgem.rake"

      FileUtils.mkdir_p "#{full_name}/src"
      File.write "#{full_name}/src/example.c", Mrb::Template.render('gem/example.c.erb', variables)
      puts "  create #{full_name}/src/example.c"

      FileUtils.mkdir_p "#{full_name}/test"
      File.write "#{full_name}/test/example.c", Mrb::Template.render('gem/test_example.c.erb', variables)
      puts "  create #{full_name}/test/example.c"
      File.write "#{full_name}/test/example.rb", Mrb::Template.render('gem/test_example.rb.erb', variables)
      puts "  create #{full_name}/test/example.rb"
    end

    desc "config", "create mruby build config"
    def config()
      text = ''
      File.open('assets/templates/build_config.rb.erb') do |fin|
        text = fin.read
      end

      File.open('./build_config.rb', 'w') do |fout|
        fout.puts text
      end
    end

    desc "version", "show version number"
    def version()
      puts Mrb::VERSION
    end
  end
end
