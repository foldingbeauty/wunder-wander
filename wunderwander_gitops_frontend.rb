# frozen_string_literal: true

$LOAD_PATH << '.'
require 'sinatra'
require 'lib/wunderwander/gitops_frontend.rb'

git_ops_frontend = WunderWander::GitopsFrontend.new

set :environment, ENV['GITOPS_ENVIRONMENT'] || :development
set :port, 3000
set :bind, '0.0.0.0'
set :root, File.expand_path('./frontend')

get '/' do
  @entries = git_ops_frontend.gitop_resources || []
  @public_key = git_ops_frontend.public_key || 'not available yet'
  slim :index
end
