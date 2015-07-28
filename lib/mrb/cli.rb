require 'thor'

module Mrb
  class CLI < Thor
    desc "get", "get mruby source code"
    def get()
      %x{git clone https://github.com/mruby/mruby.git}
    end

    desc "version", "show version number"
    def version()
      puts Mrb::VERSION
    end
  end
end
