class r_kvm::packages {

  package { ['wget','bzip2','socat','jq']:
    ensure => present,
  }
}
