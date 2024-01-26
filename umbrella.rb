require "http"
require "json"
puts "========================================"
puts "    Will you need an umbrella today?    "
puts "========================================"
puts "Where are you?"
location = gets.chomp
puts "Checking the weather at #{location}...."
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{ENV.fetch("GMAPS_KEY")}"
raw_gmaps_data = HTTP.get(gmaps_url)
parsed_gmaps_data = JSON.parse(raw_gmaps_data)
longitude = parsed_gmaps_data["results"][0]["geometry"]["location"]["lng"]
latitude = parsed_gmaps_data["results"][0]["geometry"]["location"]["lat"]
puts "Your coordinates are #{latitude}, #{longitude}."
pirate_weather_url = "https://api.pirateweather.net/forecast/#{ENV.fetch("PIRATE_WEATHER_KEY")}/#{latitude},#{longitude}"
raw_pirate_weather_data = HTTP.get(pirate_weather_url)
parsed_pirate_weather_data = JSON.parse(raw_pirate_weather_data)
current_temp = parsed_pirate_weather_data["currently"]["temperature"]
puts "It is currently #{current_temp}°F."
minutely_hash = parsed_pirate_weather_data.fetch("minutely", false)
if minutely_hash
  next_hour_summary = minutely_hash.fetch("summary")
  puts "Next hour: #{next_hour_summary}"
end
puts
hourly_hash = parsed_pirate_weather_data.fetch("hourly")
hourly_data_array = hourly_hash.fetch("data")
next_twelve_hours = hourly_data_array[1..12]
precip_prob_threshold = 0.10
any_precipitation = false
puts "Hours from now vs Precipitation probability"
puts
80.step(5, -5) do |probability|
  print "#{probability.to_s.rjust(2, " ")}|"
  next_twelve_hours.each do |hour|
    if hour["precipProbability"] >= precip_prob_threshold && any_precipitation == false
      any_precipitation = true
    end
    if hour["precipProbability"] * 100 >= probability
      print " * "
    end
  end
  puts
end
puts " 0+-*--*--*--*--*--*--*--*--*--*--*--*-"
puts "    1  2  3  4  5  6  7  8  9 10 11 12 "
puts
if any_precipitation
  puts "You might want to take an umbrella!"
end
