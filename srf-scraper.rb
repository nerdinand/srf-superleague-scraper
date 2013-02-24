#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'

season = 2013
round = 1

quality = 2




FileUtils.mkdir round.to_s
FileUtils.cd round.to_s

round += 159

url = "http://www.srf.ch/swisstxt/resultate/fussball/super-league/#{season}/rnd_regular_#{(round.nil?) ? 'act':round}.html"

doc = Nokogiri::HTML(open(url))

match_data = []

doc.css("tr")[1..5].each do |tr|
	tds = tr.css("td")

	date = tds[0].text
	home_team = tds[3].text
	score = tds[4].text
	guest_team = tds[5].text

	href = tds[9].children.first["href"]
	match = href.match(/^.*id=([\w-]+)&.*$/)
	id = match[1]

	match_data << {:date => date, :home_team => home_team, :score => score, :guest_team => guest_team, :id => id}
end

match_data.each do |data|
	id = data[:id]
	puts "ID #{id}"

	FileUtils.mkdir id

	open("http://www.srf.ch/player/tv/ajaxhtml5player?id=#{id}") do |player_doc|
		player_doc_string = player_doc.string

		if (url_match = player_doc_string.match(/^ var streamingUrl = '(.*)';$/))
			mark_in = player_doc_string.match(/^ var markIn = (.*);$/)[1].to_f
			mark_out = player_doc_string.match(/^ var markOut = (.*);$/)[1].to_f

			range_from = (mark_in/10).floor + 1
			range_till = (mark_out/10).ceil
			range = (range_from..range_till)

			puts "Range #{range}"

			akamai_url = url_match[1]
			base_akamai_url = akamai_url.split("/")[0..-2].join("/")+"/"

			segment_prefix = "segment"
			segment_postfix = "_2_av.ts"

			`wget -nd #{base_akamai_url}#{segment_prefix}{#{range.to_a.join ','}}#{segment_postfix} --directory-prefix="#{id}"`

			File.open "list.txt", "w" do |f| 
				range.each do |r|
					f.write "file '#{id}/#{segment_prefix}#{r}#{segment_postfix}'\n"
				end
			end

			file_name = "#{data[:date]} #{data[:home_team]} #{data[:score]} #{data[:guest_team]} #{id}.ts"
			`ffmpeg -f concat -i list.txt -c copy "#{file_name}"`

			FileUtils.rm "list.txt"
		end
	end

	FileUtils.rm_r id
end

`ls *.ts > list.m3u`
`open list.m3u`
