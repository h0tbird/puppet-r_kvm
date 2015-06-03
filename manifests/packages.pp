class r_kvm::packages {

  package { ['wget','bzip2','socat','qemu-system-x86','seabios','qemu-img','jq']:
    ensure => present,
  }
}
