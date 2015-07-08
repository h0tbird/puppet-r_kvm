class r_kvm::coreos {

  #----------------------------
  # kvm-1: ind=0, min=1, max=4
  # kvm-2: ind=1, min=5, max=8
  #----------------------------

  $ind = ("${::hostname}".match(/kvm-(\d+)/)[1] - 1) * 4
  $min = $ind + 1
  $max = $ind + 4

  #----------------------------------------------------
  # Iterate through: core-1, core-2, core-3 and core-4
  #----------------------------------------------------

  $masters = hiera('MasterHosts')
  $ceph_drives = hiera('CephDataDrives')
  $hdfs_drives = hiera('HDFSDataDrives')

  range("${min}", "${max}").each |$index, $id| {

    # Setup 'role' and 'masterid' metaparams:
    if "core-${id}" in $masters {
      $role = 'master'
      $masterid = inline_template("<%= @masters.index(\"core-#{@id}\") + 1%>")
    } else { $role = 'slave' }

    file {

      ["/root/coreos/core-${id}",
       "/root/coreos/core-${id}/conf",
       "/root/coreos/core-${id}/conf/openstack",
       "/root/coreos/core-${id}/conf/openstack/latest"]:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755';

      "/root/coreos/core-${id}/conf/openstack/latest/user_data":
        ensure  => file,
        content => template("${module_name}/cloud-config.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644';

      "/root/coreos/core-${id}/conf/coreos.conf":
        ensure  => file,
        content => template("${module_name}/coreos.conf.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644';

      "/root/coreos/core-${id}/core-${id}.img":
        ensure   => file,
        source   => '/root/coreos/common/coreos.img',
        replace  => false,
        checksum => 'mtime',
        owner    => 'root',
        group    => 'root',
        mode     => '0644',
        require  => Exec['download_coreos'];
    }

    if $role == 'master' {

      file {

        "/root/coreos/core-${id}/conf/prometheus":
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0755';

        "/root/coreos/core-${id}/conf/prometheus/prometheus.yml":
          ensure  => file,
          content => template("${module_name}/prometheus.yml.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';

        "/root/coreos/core-${id}/conf/prometheus/prometheus.rules":
          ensure  => file,
          content => template("${module_name}/prometheus.rules.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';
      }
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
