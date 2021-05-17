def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument

dns_raw = File.readlines("zone")

def parse_dns(dns)
  dns.reject { |line| line[0] == "#" }.
    map { |line| line.split(",").map(&:strip) }.
    reject { |record| record.length < 3 }.
    each_with_object({}) do |record, records|
    records[record[1]] = {
      type: record[0],
      target: record[2],
    }
  end
end

def resolve(dns_records, lookup_chain, domain)
  if dns_records.include? domain
    lookup_chain << dns_records[domain][:target]
    resolve(dns_records, lookup_chain, dns_records[domain][:target])
    return lookup_chain
  else
    return ["Error: record not found for #{domain}"]
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)

puts lookup_chain * " => "
