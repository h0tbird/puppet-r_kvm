class r_kvm::kvm {

  #-------------------
  # Install packages:
  #-------------------

  package { ['qemu-system-x86','seabios','qemu-img','numactl']:
    ensure => present,
  }

  #--------------------------
  # Kernel samepage merging:
  #--------------------------

  if hiera('KSM') {

    file { '/etc/ksmtuned.conf':
      ensure  => present,
      content => template("${module_name}/kvm/ksmtuned.conf.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['qemu-system-x86'],
    } ~>

    service { ['ksm', 'ksmtuned']:
      ensure => running,
      enable => true,
    }
  }
}
