require 'yaml'

class ChidConfig

  attr_reader :chid_path, :home_path, :chid_config_path

  def initialize
    @chid_path = Dir.pwd
    @home_path = File.expand_path("~/")
    @chid_config_path = File.join(home_path, '.chid.config')
  end

  def configure
    create_chid_alias_on_bashrc
    create_an_empty_chid_config_file
  end

  def username
    on_linux { return  %x[echo $USER].strip }
    on_osx   { return  %x[echo $(logname)].strip }
  end

  def on_linux
    if  platform =~ /Linux/
      yield
    end
  end

  def on_osx
    if  platform =~ /Darwin/
      yield
    end
  end

  def platform
    %x{echo $(uname -s)}.strip
  end

  def chid_rake_path
    data = YAML.load_file chid_config_path
    data[:chid][:chid_path]
  end

  def all_workstations
    data = YAML.load_file chid_config_path
    data[:chid][:workstations]
  end

  def destroy_workstations(workstations = [])
    chid_config_path = File.join(home_path, '.chid.config')

    data = YAML.load_file chid_config_path

    workstations.each do |w|
      data[:chid][:workstations].delete_if { |key, value| key == w }
    end

    File.open(chid_config_path, 'w') do |file|
      YAML.dump(data, file)
    end
  end

  def create_workstation(name, apps = [])
    chid_config_path = File.join(home_path, '.chid.config')

    data = YAML.load_file chid_config_path

    data[:chid][:workstations][:"#{name}"] = apps

    File.open(chid_config_path, 'w') do |file|
      YAML.dump(data, file)
    end
  end

  private
  def create_chid_alias_on_bashrc
    print "Creating the chid alias on your "
    print ".bashrc\n\n".blue

    File.open(File.join(home_path, '.bashrc'), 'a') do |file|
      file.write "\nalias chid='rake -f #{chid_path}/Rakefile'" unless chid_config_file_exist?
    end
  end

  def chid_config_file_exist?
    File.exist?(chid_config_path)
  end

  def create_an_empty_chid_config_file
    base_config = {
      chid: {
        chid_path: chid_path,
        workstations: {}
      }
    }
    File.open(chid_config_path, 'w') do |file|
      YAML.dump(base_config, file)
    end
  end

end