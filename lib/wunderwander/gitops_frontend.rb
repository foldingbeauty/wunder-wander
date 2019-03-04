# frozen_string_literal: true

$LOAD_PATH << '.'
require 'k8s-client'
require 'git'
require 'sshkey'
require 'base64'
require 'fileutils'
require 'net/ssh'
require 'uri/ssh_git'
require 'lib/k8s_helpers'
require 'lib/git_helpers'
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
