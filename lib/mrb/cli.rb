require 'thor'
require 'erb'
require 'fileutils'
require 'yaml'

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
        :internal_name => full_name.gsub(/-/, '_'),
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

    desc "config yml", "create mruby build config"
    def config(file)
      yaml = YAML.load_file(file)

      text = ''
      if yaml.key?('build')
        yaml['build'].keys.each do |name|
          config = yaml['build'][name]
          config['name'] = name
          text << Mrb::Template.render_config('config/build_config_host.erb', config)
        end
      end

      if yaml.key?('cross_build')
        yaml['cross_build'].keys.each do |name|
          config = yaml['cross_build'][name]
          config['name'] = name
          text << Mrb::Template.render_config('config/build_config_crossbuild.erb', config)
        end
      end

      puts "Creating build_config.rb"
      File.write "./build_config.rb", text.gsub(/^$\n/, '')
    end

    desc "version", "show version number"
    def version()
      puts Mrb::VERSION
    end
  end
end
