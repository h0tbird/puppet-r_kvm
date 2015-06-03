class r_kvm::ssh {

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
}
