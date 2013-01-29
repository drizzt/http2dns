require 'sinatra'
require 'json'

get '/:host' do |host|
	dns = Resolv::DNS.new(nameserver: %w(8.8.8.8 8.8.4.4))
	[Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A].flat_map do |klass|
		dns.getresources(host, klass).collect {|r| [r.ttl, r.address.to_s]}
	end.to_json
end
