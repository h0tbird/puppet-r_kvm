class r_kvm {

  anchor { "${module_name}_start":      } ->
  class  { "::${module_name}::docker":  } ->
  class  { "::${module_name}::scripts": } ->
  class  { "::${module_name}::ssh":     } ->
  class  { "::${module_name}::coreos":  } ->
  anchor { "${module_name}_end":        }

  #-----------
  # Packages:
  #-----------

  package { ['wget','bzip2','socat','qemu-system-x86','seabios','qemu-img','jq']:
    ensure => present,
  }
}
