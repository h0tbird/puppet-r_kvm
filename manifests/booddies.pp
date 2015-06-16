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
      require => Package['booddies'],
      before  => Service['boot','cgit','data','gito','regi'],
    }
  }

  #---------------------
  # Start the services:
  #---------------------

  if "${::hostname}" == 'kvm-1' {

    ['boot','cgit','data','gito','regi'].each |$service| {

      service { "${service}":
        ensure    => running,
        enable    => true,
        subscribe => File["/etc/booddies/${service}.conf"],
      }
    }
  }
}
