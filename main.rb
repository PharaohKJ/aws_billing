# coding: utf-8
require 'aws-sdk-core'
require 'CSV'
require_relative 'env'
require 'yaml'
require 'text-table'
# require 'colorize'

Aws.config = CONFIG

# Region指定する場合は
s3 = Aws::S3::Client.new
buf = []
p BUCKET
# p s3.get_object(BUCKET)
# puts YAML.dump(s3)
s3.get_object(BUCKET) do |chunk|
  # puts YAML.dump(chunk)
  chunk.split("\n").each do |l|
    buf << l
  end
end
csv = CSV.new(buf[1..-1].join("\n"), headers: true)

pay = {}
payment = {}
payment_description = {}

def acceptable_line?(l)
  return true if l['RecordType'] == 'PayerLineItem'
  return true if l['RecordType'] == 'LinkedLineItem'
  return false if l['TotalCost'].nil?
  false
end

def payment_key(project, linked)
  "#{linked}-#{project}"
end

def payment_description_key(project, linked, desc)
  "#{payment_key(project, linked)}-#{desc}"
end

# filter
csv.each do |l|
  next unless acceptable_line?(l)
  project = l['user:Project'].to_s == ''    ? 'none': l['user:Project']
  linked  = l['LinkedAccountId'].to_s == '' ? 'none': l['LinkedAccountId']
  pay[payment_key(project, linked)] = [] if pay[payment_key(project, linked)].nil?
  pay[payment_key(project, linked)] << l
end

pay.each do |k, l|
  l.sort! { |a, b| a['ProductName'] <=> b['ProductName'] }
  l.each do |p|
    next if p['TotalCost'].to_f < 0.001
    puts "Poject:#{k} #{p['ProductName']} : #{p['ItemDescription']} \n #{p['TotalCost']}"
    payment["#{k}"] = 0 if payment["#{k}"].nil?
    payment['total'] = 0 if payment['total'].nil?
    payment_description["#{k}-#{p['ProductName']}"] = 0 if payment_description["#{k}-#{p['ProductName']}"].nil?
    cost = p['TotalCost'].to_f
    payment["#{k}"] += cost
    payment['total'] += cost
    payment_description["#{k}-#{p['ProductName']}"] += cost
  end
  puts '---------'
end

payment.each do |k, l|
  puts "#{k} : #{l} (#{l / payment['total']})"
end

table = Text::Table.new
yen = YPD.to_f

table.head = ['PayID', 'Tag', 'Item', '$', "Yen(#{yen.to_i}/$)", '%']

payment_description.each do |k, l|
  table.rows << (
    Array(k.split('-')) +
    Array('%.5f' % l) +
    Array('%.2f' % (l * yen)) +
    Array('%8.3f' % (l / payment['total'] * 100))
  )
end

table.align_column 4, :right
table.align_column 5, :right
table.align_column 6, :right

puts table.to_s
