class r_kvm {

  #------------------------------
  # Packages and helper scripts:
  #------------------------------

  package { ['wget','bzip2','socat','qemu-system-x86','seabios','qemu-img','jq']:
    ensure => present,
  }

  ['coreup', 'pupply', 'coretach', 'coredown'].each |$file| {

    file { "/usr/local/sbin/${file}":
      ensure  => present,
      content => template("${module_name}/${file}.erb"),
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
    }
  }

  #-------------------------------------------------
  # Permissions and ownership for SSH pass-through:
  #-------------------------------------------------

  file {

    '/root/.ssh':
      ensure => directory,
      owner  => 'root',
      group  => '500',
      mode   => '0750';

    '/root/.ssh/authorized_keys':
      ensure => file,
      owner  => 'root',
      group  => '500',
      mode   => '0640';

  } <- Ssh::Key <| |>

  #----------------------------
  # kvm01: ind=0, min=1, max=4
  # kvm02: ind=1, min=5, max=8
  #----------------------------

  $ind = ("${::hostname}".match(/kvm-(\d+)/)[1] - 1) * 4
  $min = sprintf("%02d", $ind+1)
  $max = sprintf("%02d", $ind+4)

  #----------------------------------------------------
  # Iterate through: core01, core02, core03 and core04
  #----------------------------------------------------

  $masters = hiera('MasterHosts')

  range("core-${min}", "core-${max}").each |$id| {

    if "${id}" in $masters { $role = 'master' }
    else { $role = 'slave' }

    file {

      ["/root/coreos/${id}",
       "/root/coreos/${id}/conf",
       "/root/coreos/${id}/conf/openstack",
       "/root/coreos/${id}/conf/openstack/latest"]:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755';

      "/root/coreos/${id}/conf/openstack/latest/user_data":
        ensure  => file,
        content => template("${module_name}/cloud-config.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644';

      "/root/coreos/${id}/${id}.img":
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

  #---------------------------------
  # Download the CoreOS disk image:
  #---------------------------------

  file { ['/root/coreos','/root/coreos/common']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  } ->

  exec { 'download_coreos':
    command => 'wget -O - http://data01/coreos/coreos_qemu.img.bz2 | bzcat > /root/coreos/common/coreos.img',
    creates => '/root/coreos/common/coreos.img',
    path    => '/usr/bin',
  }
}
