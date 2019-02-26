$LOAD_PATH << '.'
require "sinatra"
require 'lib/k8s_helpers'
require 'lib/log_helpers'

module WunderWander
  class GitopsFrontend
    def initialize()
      @logger = LogHelpers::create_logger
      @k8s_client = K8sHelpers::Client.new
      @logger.info '---'
      @logger.info 'WunderWander GitOps Frontend v0.1.1'
      @logger.info '---'
    end

    def wait_for_public_key
      loop do
        begin
          if public_key
            @logger.info 'Found Public SSH key, start UI service'
            break
          else
            @logger.info 'Wait for secret'
            sleep(10)
          end
        end
      end
    end
    
    def public_key
      @logger.info 'Retreiving Public SSH key'
      public_key = @k8s_client.public_key
    end

    def gitop_resources
      @k8s_client.gitop_resources
    end
 end
end

git_ops_frontend = WunderWander::GitopsFrontend.new()
git_ops_frontend.wait_for_public_key

set :environment, :development
set :port, 3000
set :bind, '0.0.0.0'
set :root, File.expand_path('./frontend')

get '/' do
  @entries = git_ops_frontend.gitop_resources || []
  @public_key =  git_ops_frontend.public_key || 'not available yet'
  slim :index
end


