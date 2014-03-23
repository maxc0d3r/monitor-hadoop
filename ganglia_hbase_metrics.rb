#!/usr/local/rvm/rubies/ruby-1.9.3-p286/bin/ruby

require 'json'
require 'gmetric'
require 'nokogiri'
require 'open-uri'

if ARGV.length == 0
  puts "Usage: ganglia_hbase_metrics.rb REGION_SERVER_FQDN:PORT"
end

if ENV["GANGLIA_SERVER"].nil?
  puts "Please export environment variable GANGLIA_SERVER before using this script."
end

if ENV["GANGLIA_PORT"].nil?
  puts "Please export environment variable GANGLIA_PORT before using this script."
end

page = Nokogiri::HTML(open("http://#{ARGV[0]}/rs-status"))
metrics_hash = Hash.new
group = "HBase"
url = ENV["GANGLIA_SERVER"]
port = ENV["GANGLIA_PORT"]

page.css('table#attributes_table td')[7].text.split(',').each do |hash_map|
  key,value = hash_map.split('=')
  metrics_hash[key]=value
end

metrics_hash.each do |metrics,value|
  unless metrics.include?("Histogram")
    Ganglia::GMetric.send("#{url}",port.to_i, {
      :name => "#{metrics}",
      :value => value.tr('%',''),
      :type => 'uint16',
      :tmax => 60,
      :dmax => 300,
      :group => "#{group}"
    })
  end
end
