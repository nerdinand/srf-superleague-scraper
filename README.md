srf-superleague-scraper
=======================

A simple ruby script, that scrapes the srf website to extract the summary-clips of the super league football games. 

Dependencies
============

This script depends on:
* nokogiri gem
* wget
* ffmpeg

Usage
=====

Change the variables season, round and quality to your liking, then run the script. It will create a directory with the season number and download the summary clips of the selected season and round into that directory. In my tests, the akamai CDN that SRF uses, can take quite a while to respond to some of the wget requests. Maybe I also hit some kind of per-IP-limit during testing.

Variables
=========

_season_

The season of the super league you want to download from.

_round_

The round of the super league you want to download the clips from.

_quality_

The video file quality (0 to 2), where 0 is the worst and 2 the best quality.
