require 'net/ssh'

# Utils to work with Git
module GitHelpers
  LOCAL_GIT_STORAGE = './tmp'.freeze
  DEFAULT_PULL_FREQENCY = 10

  # Git Client to abstract away implementation
  class Client
    def initialize(repo, repo_name, repo_branch, logger)
      @repo = repo
      @repo_name = repo_name
      @repo_storage_directory = GitHelpers::LOCAL_GIT_STORAGE + '/' + @repo_name
      @repo_branch = repo_branch
      @logger = logger
      Git.configure do |config|
        config.git_ssh = File.expand_path 'access.sh'
      end
      @client = nil
    end

    def check_ssh_connection(host, user)
      @logger.info "Check SSH connection to #{host}"
      loop do
        has_connection = GitHelpers.test_ssh_connection host, user
        break if has_connection

        @logger.info "Can connect to Git repo #{host}"
        @logger.info "Retry in #{DEFAULT_PULL_FREQENCY} seconds."
        sleep(GitHelpers::DEFAULT_PULL_FREQENCY)
      end
      @logger.info "SSH connection to #{host} OK!"
      @logger.info '---'
    end

    def checkout_location
      @repo_storage_directory
    end

    def prepare
      if Dir.exist?(@repo_storage_directory)
        @client = Git.open(@repo_storage_directory, log: @logger)
      else
        @client = Git.clone(@repo, @repo_name, path: GitHelpers::LOCAL_GIT_STORAGE, log: @logger)
      end
    end

    def pull
      @client.pull
      @current_commit_ref = @client.revparse('HEAD')
      @changed = @current_commit_ref != @previous_commit_ref
      @previous_commit_ref = @current_commit_ref
    end

    def ref
      @current_commit_ref
    end

    def changed?
      @changed
    end
  end

  def self.test_ssh_connection(host, user)
    Net::SSH.start(
      host, user,
      keys: ['/app/.ssh/id_rsa'], &:close
    )
    true
  rescue StandardError
    false
  end
end
