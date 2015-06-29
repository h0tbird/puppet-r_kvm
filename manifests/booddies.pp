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

    file { $file:
      path    => "/etc/booddies/${file}.conf",
      ensure  => file,
      content => template("${module_name}/${file}.conf.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['booddies'],
    }
  }

  $leases = hiera('DnsmasqLeases')

  file {

    '/data/boot/dnsmasq/dnsmasq.leases':
      ensure  => file,
      content => template("${module_name}/dnsmasq.leases.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      replace => false,
      before  => File['boot'];

    '/data/boot/dnsmasq/dhcp_hosts':
      ensure  => file,
      content => template("${module_name}/dhcp_hosts.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      before  => File['boot'];
  }

  #---------------------
  # Start the services:
  #---------------------

  if "${::hostname}" == 'kvm-1' {

    ['boot','cgit','data','gito','regi'].each |$service| {

      service { $service:
        ensure    => running,
        enable    => true,
        require   => File['boot','cgit','data','gito','regi'],
        subscribe => File["${service}"],
      }
    }
  }
}
