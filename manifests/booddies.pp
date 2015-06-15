class r_kvm::booddies {

  #----------------------
  # Install the package:
  #----------------------

  package { 'booddies':
    ensure => latest,
  }

  #-------------------------
  # Configure the services:
  #-------------------------

  $config = hiera('Booddies')

  ['boot','cgit','data','gito','regi'].each |$file| {

    file { "/etc/booddies/${file}.conf":
      ensure  => file,
      content => template("${module_name}/${file}.conf.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['booddies'];
    }
  }
}
