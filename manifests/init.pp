class r_kvm {

  contain ::r_base

  package { ['wget','bzip2','socat','qemu-system-x86','seabios','qemu-img','jq']:
    ensure => present,
  }

  ['coreup', 'pupply', 'coretach', 'coredown'].each |$value| {

    file { "/usr/local/sbin/${value}":
      ensure  => present,
      content => template("${module_name}/${value}.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }
  }

  $i = ("${::hostname}".match(/kvm(\d+)/)[1] - 1) * 4
  $a = sprintf("%02d", $i+1)
  $b = sprintf("%02d", $i+4)

  range("core${a}", "core${b}").each |$value| {

    file {

      "/root/coreos/${value}":
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755';

      "/root/coreos/${value}/${value}.img":
        ensure   => file,
        source   => '/root/coreos/common/coreos.img',
        replace  => false,
        checksum => 'mtime',
        owner    => 'root',
        group    => 'root',
        mode     => '0644',
        require  => Exec['download_coreos'];
    }
  }

  file { ['/root/coreos','/root/coreos/common']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->

  exec { 'download_coreos':
    command => 'wget -O - http://data01.demo.lan/coreos/coreos_qemu.img.bz2 | bzcat > /root/coreos/common/coreos.img',
    creates => '/root/coreos/common/coreos.img',
    path    => '/usr/bin',
  }
}
