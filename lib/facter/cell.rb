if Facter.value(:kernel) == 'Linux'
  Facter.add('cell') do
    setcode do
      %x{cat /proc/sys/kernel/hostname | sed -r 's/.*cell-([0-9]*).*/\\1/'}.to_i
    end
  end
end
