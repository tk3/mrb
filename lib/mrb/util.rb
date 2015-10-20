module Mrb
  class Util
    def self.gen_names(name)
      if m = name.match(/^mruby-(.*)/)
        full_name = name
        name = m[1]
      else
        full_name = "mruby-#{name}"
        name = name
      end

      {
        :full_name => full_name,
        :internal_name => full_name.gsub(/-/, '_'),
        :name => name,
      }
    end
  end
end
