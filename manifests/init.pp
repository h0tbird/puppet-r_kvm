class r_kvm {

  contain ::r_base

  file { '/usr/local/sbin/coreup':
    ensure  => present,
    content => template("${module_name}/coreup.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
}
