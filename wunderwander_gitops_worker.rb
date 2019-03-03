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
  class GitopsWorker
    def initialize
      @logger = LogHelpers.create_logger
      @k8s_client = K8sHelpers::Client.new @logger
      @logger.info '---'
      @logger.info "WunderWander GitOps Worker v#{WunderWanderHelpers::VERSION}"
      @logger.info '---'
      @deployment_name_space = ENV['GITOPS_NAMESPACE'] || 'test'
      initialize_git
      initialize_namespace
    end

    def initialize_git
      git_branch = ENV['GIT_BRANCH'] || 'master'
      git_repo = ENV['GIT_REPO'] || 'git@github.com:foldingbeauty/wunderwander-test-app.git'
      git_name = ENV['GIT_NAME'] || 'wunderwander'
      @logger.info "Initialize Git with name #{git_name} --> #{git_branch} :: #{git_repo}"
      @git = GitHelpers::Client.new git_repo, git_name, git_branch, @logger
      @git_repo_parsed = URI::SshGit.parse(git_repo)
    end

    def initialize_namespace
      @logger.info "Create deployment namespace #{@deployment_name_space}"
      @k8s_client.create_namespace @deployment_name_space
    end

    def observe_and_act
      @git.pull
      return if @git.no_change?

      @logger.info "Deployment changed, update deployment with ref #{@git.ref}"
      resources = K8s::Resource.from_files(@git.checkout_location)
      resources.each do |resource|
        @k8s_client.deploy_resource(@deployment_name_space, resource)
      end
    end

    def start_worker
      @git.check_ssh_connection(@git_repo_parsed.host, @git_repo_parsed.user)
      @git.prepare
      loop do
        observe_and_act
        @logger.info "Next check in #{WunderWanderHelpers::DEFAULT_PULL_FREQENCY} seconds"
        @logger.info '---'
        sleep(WunderWanderHelpers::DEFAULT_PULL_FREQENCY)
      end
    end
  end
end

git_ops_worker = WunderWander::GitopsWorker.new
git_ops_worker.start_worker
