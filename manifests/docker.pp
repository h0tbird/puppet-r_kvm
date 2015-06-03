class r_kvm::docker {

  package { 'docker':
    ensure => latest,
  } ->

  file {

    '/etc/sysconfig/docker':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644';

    '/etc/sysconfig/docker-storage':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644';

    '/etc/sysconfig/docker-network':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0644';
  } ->

  service { 'docker':
    ensure => 'running',
    enable => true,
  }
}
