task :default, [:ym] do |_a, param|
  ENV['YM'] = param[:ym] unless param[:ym].nil?
  sh 'bundle exec ruby main.rb'
end
