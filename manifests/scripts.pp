class r_kvm::scripts {

  #--------------------------------
  # Deploy all the helper scripts:
  #--------------------------------

  ['coreup', 'pupply', 'coretach', 'coredown'].each |$file| {

    file { "/usr/local/sbin/${file}":
      ensure  => present,
      content => template("${module_name}/kvm/${file}.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }
  }
}
