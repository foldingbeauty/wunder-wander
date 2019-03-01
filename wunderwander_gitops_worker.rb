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
require 'lib/wunderwander_helpers'

DEFAULT_PULL_FREQENCY = 10

def setup_logger
  $stdout = IO.new(IO.sysopen('/proc/1/fd/1', 'w'), 'w')
  $stdout.sync = true
  logger = Logger.new($stdout)
  logger.info '---'
  logger.info "WunderWander GitOps Worker v#{WunderWanderHelpers::VERSION}"
  logger.info 'Lets get to work!'
  logger.info '---'
  logger
end

def check_for_changes_and_deploy(git, logger, k8s_client, deployment_name_space)
  git.pull
  return if git.changed?

  logger.info "Deployment changed, update deployment with ref #{git.ref}"
  resources = K8s::Resource.from_files(git.checkout_location)
  resources.each do |resource|
    k8s_client.deploy_resource(deployment_name_space, resource)
  end
end

logger = setup_logger

# create Kubernetes client
k8s_client = K8sHelpers::Client.new logger

# create namespace
deployment_name_space = ENV['GITOPS_NAMESPACE'] || 'test'
logger.info "Create deployment namespace #{deployment_name_space}"
k8s_client.create_namespace deployment_name_space

# check if can connect to git repo
git_branch = ENV['GIT_BRANCH'] || 'develop'
git_repo = ENV['GIT_REPO'] || 'git@github.com:wunderwander/gitops.git'
git_name = ENV['GIT_NAME'] || 'wunderwander'

git = GitHelpers::Client.new git_repo, git_name, git_branch, logger
git_repo_parsed = URI::SshGit.parse(git_repo)
git.check_ssh_connection(git_repo_parsed.host, git_repo_parsed.user)

# setup GIT to use predifined key
git.prepare
loop do
  check_for_changes_and_deploy(git, logger, k8s_client, deployment_name_space)
  sleep(DEFAULT_PULL_FREQENCY)
end
