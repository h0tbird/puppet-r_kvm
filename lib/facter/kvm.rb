if Facter.value(:kernel) == 'Linux'
  Facter.add('kvm') do
    setcode do
      %x{cat /proc/sys/kernel/hostname | sed -r 's/.*kvm-([0-9]*).*/\\1/'}.to_i
    end
  end
end
