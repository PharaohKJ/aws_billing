# coding: utf-8
require 'aws-sdk-core'
require 'CSV'
require_relative 'env'

Aws.config = CONFIG

# Region指定する場合は
s3 = Aws::S3::Client.new
buf = []
p BUCKET
s3.get_object(BUCKET) do |chunk|
  chunk.split("\n").each do |l|
    buf << l
  end
end

csv = CSV.new(buf[1..-1].join("\n"), headers: true)

pay = {}
payment = {}

csv.each do |l|
  next unless l['InvoiceID'] == 'Estimated'
  next unless l['RecordType'] == 'PayerLineItem'
  next if l['TotalCost'].nil?
  project = l['user:Project'] || 'none'
  pay[project] = [] if pay[project].nil?
  pay[project] << l
end

pay.each do | k, l |
  l.each do |p|
    puts "#{k} #{p['ProductName']} : #{p['TotalCost']}"
    payment["#{k}"] = 0 if payment["#{k}"].nil?
    payment['total'] = 0  if payment['total'].nil?
    cost = p['TotalCost'].to_f
    payment["#{k}"] += cost
    payment['total'] += cost
  end
end

payment.each do | k, l |
  puts "#{k} : #{l} (#{l / payment['total']})"
end
