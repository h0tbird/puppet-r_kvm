class r_kvm::docker {

  package { 'docker':
    ensure => latest,
  } ->

  file {

    '/etc/sysconfig/docker':
      ensure  => present,
      content => template("::${module_name}/docker.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';

    '/etc/sysconfig/docker-storage':
      ensure  => present,
      content => template("::${module_name}/docker-storage.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';

    '/etc/sysconfig/docker-network':
      ensure  => present,
      content => template("::${module_name}/docker-network.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';
  } ~>

  service { 'docker':
    ensure => 'running',
    enable => true,
  }
}
