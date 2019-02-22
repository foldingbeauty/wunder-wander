# check for CRD entries and deploy a git_processor.rb for specific entry
$LOAD_PATH << '.'
require 'k8s-client'
require 'lib/k8s_helpers'
require 'lib/log_helpers'

module WunderWander
  class GitopsOperator
    def initialize()
      @logger = LogHelpers::create_logger
      @k8s_client = K8sHelpers::Client.new
      @logger.info '---'
      @logger.info 'WunderWander GitOps Operator v0.1.0'
      @logger.info '---'
      
      # create secret
      @k8s_client.create_key_pair
    end

    def observe_gitops_resources_and_act
      api = @k8s_client.client.api('io.wunderwander/v1')
      gitops = api.resource('gitops', namespace: K8sHelpers::GITOPS_NAMESPACE)
      gitops.list.each do |resource|
        processor_template = 'config/gitops-processor-deployment.yaml'
        processor = K8s::Resource.from_file(processor_template)
        processor.metadata.namespace = K8sHelpers::GITOPS_NAMESPACE
        processor.metadata.name = resource.metadata.name
        spec_template = processor.spec.template
        spec_template.metadata.labels.app = resource.metadata.name
        spec_template.spec.containers[0].env[0].value = resource.spec.branch
        spec_template.spec.containers[0].env[1].value = resource.spec.repo
        spec_template.spec.containers[0].env[2].value = resource.metadata.name
        @logger.info "Deploy processor for #{resource.metadata.name}"
        begin
          @k8s_client.client.get_resource(processor)
          @logger.info "Processor for #{resource.metadata.name} already deployed"
        rescue K8s::Error::NotFound
          @k8s_client.client.create_resource(processor)
          @logger.info "Processor for #{resource.metadata.name} deployed"
        end
      end
      @logger.info 'Next check for WunderWander Gitops resources in 10 seconds'
      @logger.info '---'
      sleep(10)
    end
  end
end

git_ops_operator = WunderWander::GitopsOperator.new()
loop do
  git_ops_operator.observe_gitops_resources_and_act()
end
