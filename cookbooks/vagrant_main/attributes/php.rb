case node['platform']
  when 'ubuntu'
    if node['platform_version'].to_f >= 14.04
      override['php']['ext_conf_dir'] = '/etc/php5/mods-available'
    end
  else
end
