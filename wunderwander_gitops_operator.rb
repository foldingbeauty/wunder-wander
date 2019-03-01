# check for GitOp CRDs and deploy a worker
$LOAD_PATH << '.'
require 'k8s-client'
require 'lib/k8s_helpers'
require 'lib/log_helpers'
require 'lib/wunderwander_helpers'
require 'mustache'

module WunderWander
  # Worker template
  class GitopsWorker < Mustache
    self.template_file = 'operator/worker-template.yaml.mustache'
  end

  # Operator
  class GitopsOperator

    def initialize
      @logger = LogHelpers.create_logger
      @k8s_client = K8sHelpers::Client.new @logger

      @logger.info '---'
      @logger.info "WunderWander GitOps Operator v#{WunderWanderHelpers::VERSION}"
      @logger.info '---'

      # create secret
      @k8s_client.create_key_pair
    end

    def render_worker_template(resource)
      template = GitopsWorker.new
      template[:name] = "worker-#{resource.metadata.name}"
      template[:image] = WunderWanderHelpers::IMAGE
      template[:git_branch] = resource.spec.branch
      template[:git_repo] = resource.spec.repo
      template[:git_name] = resource.metadata.name
      template[:gitops_namespace] = "#{resource.metadata.name}-#{resource.spec.branch}"
      template[:namespace] = K8sHelpers::GITOPS_NAMESPACE
      K8s::Resource.new(YAML.safe_load(template.render))
    end

    def deploy_worker(worker)
      @k8s_client.client.get_resource(worker)
    rescue K8s::Error::NotFound
      @k8s_client.client.create_resource(worker)
      @logger.info "Worker for #{resource.metadata.name} deployed"
    end

    def observe_and_act
      api = @k8s_client.client.api('io.wunderwander/v1')
      gitops = api.resource('gitops', namespace: K8sHelpers::GITOPS_NAMESPACE)
      gitops.list.each do |resource|
        worker = render_worker_template(resource)
        deploy_worker(worker)
      end
    end

    def start_operator
      loop do
        git_ops_operator.observe_and_act
        sleep(10)
        @logger.info 'Next check for WunderWander Gitops resources in 10 seconds'
        @logger.info '---'
      end
    end
  end
end

git_ops_operator = WunderWander::GitopsOperator.new
git_ops_operator.start_operator
