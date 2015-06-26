if Facter.value(:kernel) == 'Linux'
  %x{cat /proc/sys/kernel/hostname}.strip.split('.').reverse.each_with_index do |item, index|
    Facter.add("fqdn_#{index}") do
      setcode do
        item
      end
    end
  end
end
