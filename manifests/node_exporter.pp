class r_kvm::node_exporter {

  package { 'node_exporter':
    ensure => present,
  } ->

  service { 'node_exporter':
    ensure => running,
    enable => true,
  }
}
