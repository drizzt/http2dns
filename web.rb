require 'sinatra'
require 'json'

get '/:host' do |host|
	Resolv::DNS.new(nameserver: %w(8.8.8.8 8.8.4.4)).getaddresses(host).to_json
end
