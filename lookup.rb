def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines

dns_raw = File.readlines("zone")

def parse_dns(dns)
  #remove null sttings
  dns = dns - [""]
  return (dns.map { |recoard|
           type, source, destination = recoard.split(",").map(&:strip)
           [source, [destination, type]]
         }).to_h
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records.include? domain
    destination = dns_records[domain][0]
    lookup_chain << destination
    resolve(dns_records, lookup_chain, destination)
    return lookup_chain
  else
    return ["Error: record not found for #{domain}"]
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]

lookup_chain = resolve(dns_records, lookup_chain, domain)

puts lookup_chain.join(" => ")
