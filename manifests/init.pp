class r_kvm {

  contain ::r_base

  package { ['wget','bzip2','socat','qemu-system-x86','seabios','qemu-img','jq']:
    ensure => present,
  }

  file { '/usr/local/sbin/coreup':
    ensure  => present,
    content => template("${module_name}/coreup.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { [ '/root/coreos',
           '/root/coreos/core01',
           '/root/coreos/core02',
           '/root/coreos/core03',
           '/root/coreos/core04' ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->

  exec { 'wget -O - http://repo01.demo.lan/coreos/coreos_qemu.img.bz2 | bzcat > /root/coreos/core01/core01.img':
    path    => '/usr/bin',
    creates => '/root/coreos/core01/core01.img',
  } ->

  file { [ '/root/coreos/core02/core02.img',
           '/root/coreos/core03/core03.img',
           '/root/coreos/core04/core04.img' ]:
    ensure   => file,
    source   => '/root/coreos/core01/core01.img',
    replace  => false,
    checksum => 'mtime',
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
  }
}
