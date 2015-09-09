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
  $ceph_config = hiera('CephConfig')
  $flannel_config = hiera('Flannel')

  range("${min}", "${max}").each |$index, $id| {

    # Setup 'role' and 'masterid' metaparams:
    if "core-${id}" in $masters {
      $role = 'master'
      $masterid = inline_template("<%= @masters.index(\"core-#{@id}\") + 1%>")
    } else { $role = 'slave' }

    #-------------------
    # All core-x hosts:
    #-------------------

    file {

      ["/root/coreos/core-${id}",
       "/root/coreos/core-${id}/conf",
       "/root/coreos/core-${id}/conf/confd",
       "/root/coreos/core-${id}/conf/confd/conf.d",
       "/root/coreos/core-${id}/conf/confd/templates",
       "/root/coreos/core-${id}/conf/openstack",
       "/root/coreos/core-${id}/conf/openstack/latest"]:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755';

      "/root/coreos/core-${id}/conf/openstack/latest/user_data":
        ensure  => file,
        content => template("${module_name}/coreos/cloud-config.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644';

      "/root/coreos/core-${id}/conf/coreos.conf":
        ensure  => file,
        content => template("${module_name}/coreos/coreos.conf.erb"),
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

      #-------------------
      # Confd: /etc/hosts
      #-------------------

      "/root/coreos/core-${id}/conf/confd/conf.d/hosts.toml":
        ensure  => file,
        content => template("${module_name}/confd/hosts.toml.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644';

      "/root/coreos/core-${id}/conf/confd/templates/hosts.tmpl":
        ensure  => file,
        content => template("${module_name}/confd/hosts.tmpl.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => '0644';
    }

    #---------------
    # Masters only:
    #---------------

    if $role == 'master' {

      file {

        #--------------------
        # Prometheus config:
        #--------------------

        "/root/coreos/core-${id}/conf/prometheus":
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0755';

        "/root/coreos/core-${id}/conf/prometheus/prometheus.yml":
          ensure  => file,
          content => template("${module_name}/prometheus/prometheus.yml.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';

        "/root/coreos/core-${id}/conf/prometheus/prometheus.rules":
          ensure  => file,
          content => template("${module_name}/prometheus/prometheus.rules.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';

        #--------------
        # Ceph config:
        #--------------

        "/root/coreos/core-${id}/conf/ceph":
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0755';

        "/root/coreos/core-${id}/conf/ceph/populate_etcd":
          ensure  => file,
          content => template("${module_name}/ceph/populate_etcd.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0755';

        #---------------------------------------------
        # Confd: /etc/prometheus/targets/cadvisor.yml
        #---------------------------------------------

        "/root/coreos/core-${id}/conf/confd/conf.d/cadvisor.toml":
          ensure  => file,
          content => template("${module_name}/confd/cadvisor.toml.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';

        "/root/coreos/core-${id}/conf/confd/templates/cadvisor.tmpl":
          ensure  => file,
          content => template("${module_name}/confd/cadvisor.tmpl.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';

        #-----------------------------------------
        # Confd: /etc/prometheus/targets/etcd.yml
        #-----------------------------------------

        "/root/coreos/core-${id}/conf/confd/conf.d/etcd.toml":
          ensure  => file,
          content => template("${module_name}/confd/etcd.toml.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';

        "/root/coreos/core-${id}/conf/confd/templates/etcd.tmpl":
          ensure  => file,
          content => template("${module_name}/confd/etcd.tmpl.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';

        #-----------------------------------------------
        # Confd: /etc/prometheus/targets/prometheus.yml
        #-----------------------------------------------

        "/root/coreos/core-${id}/conf/confd/conf.d/prometheus.toml":
          ensure  => file,
          content => template("${module_name}/confd/prometheus.toml.erb"),
          owner   => 'root',
          group   => 'root',
          mode    => '0644';

        "/root/coreos/core-${id}/conf/confd/templates/prometheus.tmpl":
          ensure  => file,
          content => template("${module_name}/confd/prometheus.tmpl.erb"),
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
