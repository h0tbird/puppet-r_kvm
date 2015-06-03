class r_kvm {

  anchor { "${module_name}_start":       } ->
  class  { "::${module_name}::packages": } ->
  class  { "::${module_name}::docker":   } ->
  class  { "::${module_name}::scripts":  } ->
  class  { "::${module_name}::ssh":      } ->
  class  { "::${module_name}::coreos":   } ->
  anchor { "${module_name}_end":         }
}
