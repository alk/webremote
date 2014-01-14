#!/usr/bin/env ruby

require 'rubygems'
gem 'sinatra', '>= 1.3.2' # for :public_folder
require 'sinatra/base'
require 'active_support/core_ext'

class Server < Sinatra::Base
  set :environment, :production
  set :port, 80
  set :public_folder, File.expand_path(File.dirname(__FILE__))
  set :static_cache_control, [:public, :max_age => 3650*24*3600]
  # set :logging, false

  def do_action(key)
    args = ["irsend", "simulate", "%016x 1 %s webremote" % [key.hash % 0x1000_0000, key]]
    puts args.inspect
    system(*args)
    args = ["irsend", "simulate", "%016x 0 %s webremote" % [key.hash % 0x1000_0000, key]]
    puts args.inspect
    system(*args)
  end

  get "/" do
    text = IO.read("index.html")
    return [200, {'Content-Type' => 'text/html; charset=utf-8'}, [text]]
  end

  get "/action/:key" do
    do_action(params[:key])
    return [200, {"Cache-Control" => "no-cache max-age=0 must-revalidate"}, [""]]
  end

  post "/:key" do
    do_action(params[:key])
    return [200, {}, [""]]
  end

end

Server.run!
