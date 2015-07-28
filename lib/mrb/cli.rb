require 'thor'

module Mrb
  class CLI < Thor
    desc "get", "get mruby source code"
    def get()
      %x{git clone https://github.com/mruby/mruby.git}
    end
  end
end
