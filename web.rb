# encoding: utf-8

require 'sinatra'
require 'resolv'

helpers do
	def resolve(host, raw = false)
		dns = Resolv::DNS.new(nameserver: %w(8.8.8.8 8.8.4.4))
		[Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A].flat_map do |klass|
			dns.getresources(host, klass).collect {|r| [r.ttl, raw ? r.address.address : r.address.to_s]}
		end
	end
end

get '/:host' do |host|
	format = params[:format] || 'msgpack'
	raw = true if params.include?('raw')
	raw = false if params.include?('noraw')
	case format
	when 'json'
		require 'json'
		content_type :json, 'charset' => 'utf-8'
		JSON.dump(resolve(host))
	when 'marshal'
		content_type 'application/x-marshal'
		Marshal.dump(resolve(host, raw.nil? ? true : raw))
	when 'msgpack'
		require 'msgpack'
		content_type 'application/x-msgpack'
		MessagePack.dump(resolve(host, raw.nil? ? true : raw))
	when 'yaml'
		require 'yaml'
		content_type :yaml
		YAML.dump(resolve(host, raw.nil? ? false : raw))
	when 'xml'
		require 'ox'
		content_type :xml
		Ox.dump(resolve(host))
	end
end
