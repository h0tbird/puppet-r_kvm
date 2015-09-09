class r_kvm::etcd {

  #-------------------
  # Install packages:
  #-------------------

  package { ['etcd','bind-utils']:
    ensure => present,
  }

  #---------------------
  # Config the service:
  #---------------------

  $masters = hiera('MasterHosts')

  file { '/lib/systemd/system/etc-hosts-record.service':
    ensure  => present,
    content => template("${module_name}/etcd/etc-hosts-record.service.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['etcd'],
    notify  => Service['etc-hosts-record'],
  }

  #--------------------
  # Start the service:
  #--------------------

  service { 'etc-hosts-record':
    ensure  => running,
    enable  => true,
  }
}
