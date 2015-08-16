class r_kvm::booddies {

  $config = hiera('Booddies')

  #----------------------
  # Install the package:
  #----------------------

  package { 'booddies':
    ensure => latest,
  }

  file { ['/var/lib/booddies','/var/log/booddies']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  ['boot','data','gito','regi'].each |$item| {

    file { $config["${item}"]['DATA_DIR']:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  #-------------------------
  # Configure the services:
  #-------------------------

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

  #---------------------------
  # Setup static DHCP leases:
  #---------------------------

  $leases = hiera('DnsmasqLeases')

  file {

    "${config['boot']['DATA_DIR']}/dnsmasq":
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';

    "${config['boot']['DATA_DIR']}/dnsmasq/dnsmasq.leases":
      ensure  => file,
      content => template("${module_name}/dnsmasq.leases.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      replace => false,
      before  => File['boot'];

    "${config['boot']['DATA_DIR']}/dnsmasq/dhcp_hosts":
      ensure  => file,
      content => template("${module_name}/dhcp_hosts.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      before  => File['boot'];
  }

  #---------------------------------------
  # Clone PXE and Kickstart repositories:
  #---------------------------------------

  vcsrepo {

    "${config['boot']['DATA_DIR']}/pxelinux":
      ensure   => present,
      provider => git,
      source   => 'http://gito01/cgit/config-pxelinux',
      revision => 'master',
      before   => File['boot'];

    "${config['data']['DATA_DIR']}/kickstart":
      ensure   => present,
      provider => git,
      source   => 'http://gito01/cgit/config-kickstart',
      revision => 'master',
      before   => File['data'];
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
