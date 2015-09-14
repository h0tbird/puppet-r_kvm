class r_kvm {

  anchor { "${module_name}_start":            } ->
  class  { "::${module_name}::packages":      } ->
  class  { "::${module_name}::kvm":           } ->
  class  { "::${module_name}::docker":        } ->
  class  { "::${module_name}::scripts":       } ->
  class  { "::${module_name}::ssh":           } ->
  class  { "::${module_name}::coreos":        } ->
  class  { "::${module_name}::node_exporter": } ->
  class  { "::${module_name}::etcd":          } ->
  class  { "::${module_name}::booddies":      } ->
  anchor { "${module_name}_end":              }
}
