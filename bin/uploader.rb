require "rubygems"
require "bundler/setup"
require "faster_csv"
require "redis"

ix = 0
redis = Redis.new
redis.flushall

FasterCSV.foreach('the-file.csv', :quote_char => "'") do |row|
  ix += 1

  if row[0] =~ /\d{5}/
    redis.set row[0], row[0]
    redis.set "#{row[0]}:counter", 0

    redis.set "#{row[0]}:state:id", row[7]
    redis.set "#{row[0]}:state:name", row[4]

    redis.set "#{row[0]}:municipality:id", row[11]
    redis.set "#{row[0]}:municipality:name", row[3]

    block_found = redis.sismember "#{row[0]}:blocks", row[1]

    unless block_found
      redis.sadd "#{row[0]}:blocks", row[1]

      puts "#{ix}: cp:#{row[0]} block:#{row[1]} municipality:#{row[3]} state:#{row[4]} state_id:#{row[7]} municipality_id:#{row[11]}"
    end
  else
    puts "no code"
  end
end
