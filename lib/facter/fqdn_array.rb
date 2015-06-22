if Facter.value(:kernel) == 'Linux'
  Facter.add('fqdn_array') do
    setcode do
      %x{cat /proc/sys/kernel/hostname}.strip.split('.').reverse
    end
  end
end
