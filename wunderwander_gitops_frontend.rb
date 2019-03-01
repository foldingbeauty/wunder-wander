# frontend for WunderWander Gitops.
$LOAD_PATH << '.'
require 'sinatra'
require 'lib/k8s_helpers'
require 'lib/log_helpers'
require 'lib/wunderwander_helpers'

module WunderWander
  # frontend stuff
  class GitopsFrontend
    def initialize
      @logger = LogHelpers.create_logger
      @k8s_client = K8sHelpers::Client.new @logger
      @logger.info '---'
      @logger.info "WunderWander GitOps Frontend v#{WunderWanderHelpers::VERSION}"
      @logger.info '---'
    end

    def public_key
      @logger.info 'Retreiving Public SSH key'
      @k8s_client.public_key
    end

    def gitop_resources
      @k8s_client.gitop_resources
    end
  end
end

git_ops_frontend = WunderWander::GitopsFrontend.new
sleep(10) until git_ops_frontend.public_key

set :environment, :development
set :port, 3000
set :bind, '0.0.0.0'
set :root, File.expand_path('./frontend')

get '/' do
  @entries = git_ops_frontend.gitop_resources || []
  @public_key = git_ops_frontend.public_key || 'not available yet'
  slim :index
end
