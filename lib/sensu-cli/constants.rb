module SensuCli
  SETTINGSDIRECTORY = "#{Dir.home}/.sensu"
  SETTINGSFILES = %W(#{SETTINGSDIRECTORY}/settings.rb /etc/sensu/sensu-cli/settings.rb)
end
