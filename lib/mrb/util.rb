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

    def self.git_clone_command(mruby_repo_url, version, mrb_config_path)
      git_cone_cmd = "git clone --depth=1 "
      git_cone_cmd << " -b #{version} "    unless version.casecmp("master") == 0
      git_cone_cmd << " #{mruby_repo_url} #{mrb_config_path}/#{version}"
    end
  end
end
