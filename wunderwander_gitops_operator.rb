# check for GitOp CRDs and deploy a worker
$LOAD_PATH << '.'
require 'k8s-client'
require 'lib/k8s_helpers'
require 'lib/log_helpers'

module WunderWander
  # Operator
  class GitopsOperator
    WORKER_TEMPLATE = 'operator/worker-template.yaml'.freeze

    def initialize
      @logger = LogHelpers.create_logger
      @k8s_client = K8sHelpers::Client.new @logger
      @logger.info '---'
      @logger.info 'WunderWander GitOps Operator v0.1.1'
      @logger.info '---'

      # create secret
      @k8s_client.create_key_pair
    end

    def populate_worker_template resource
      worker_template = WORKER_TEMPLATE
      worker = K8s::Resource.from_file(worker_template)
      worker.metadata.namespace = K8sHelpers::GITOPS_NAMESPACE
      worker_name = "worker-#{resource.metadata.name}"
      worker.metadata.name = worker_name
      spec_template = worker.spec.template
      spec_template.metadata.labels.app = worker_name
      spec_template.spec.containers[0].env[0].value = resource.spec.branch
      spec_template.spec.containers[0].env[1].value = resource.spec.repo
      spec_template.spec.containers[0].env[2].value = resource.metadata.name
      spec_template.spec.containers[0].env[3].value = "#{resource.metadata.name}-#{resource.spec.branch}"
      return worker
    end

    def observe_and_act
      api = @k8s_client.client.api('io.wunderwander/v1')
      gitops = api.resource('gitops', namespace: K8sHelpers::GITOPS_NAMESPACE)
      gitops.list.each do |resource|
        worker = populate_worker_template(resource)
        @logger.info "Deploy worker for #{resource.metadata.name}"
        begin
          @k8s_client.client.get_resource(worker)
          @logger.info "Worker for #{resource.metadata.name} already deployed"
        rescue K8s::Error::NotFound
          @k8s_client.client.create_resource(worker)
          @logger.info "Worker for #{resource.metadata.name} deployed"
        end
      end
      @logger.info 'Next check for WunderWander Gitops resources in 10 seconds'
      @logger.info '---'
      sleep(10)
    end
  end
end

git_ops_operator = WunderWander::GitopsOperator.new
loop do
  git_ops_operator.observe_and_act
end
