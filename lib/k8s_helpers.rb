require 'k8s-client'
require 'net/ssh'
require 'sshkey'

# Helper utils for Kubernetes
module K8sHelpers
  DEFAULT_K8S_CONFIG = '.kube/config'.freeze
  GITOPS_CRD_NAME = 'gitops.io.wunderwander'.freeze
  GITOPS_NAMESPACE = 'wunderwander-gitops'.freeze

  # Wrapper around Kubernetes client
  class Client
    attr_reader :client

    def initialize
      @client = if File.exist?(File.expand_path(K8sHelpers::DEFAULT_K8S_CONFIG))
                  K8s::Client.config(
                    K8s::Config.load_file(
                      File.expand_path(K8sHelpers::DEFAULT_K8S_CONFIG)
                    )
                  )
                else
                  K8s::Client.in_cluster_config
                end
    end

    def create_key_pair_resource
      K8s::Resource.new(
        apiVersion: 'v1',
        kind: 'Secret',
        metadata: {
          namespace: K8sHelpers::GITOPS_NAMESPACE,
          name: 'ssh-keys',
          type: 'Opaque'
        }
      )
    end

    def resource_exists? resource
      begin
        available = @client.get_resource(resource)
        return true if available
      rescue K8s::Error::NotFound
        return false
      end
    end

    def generate_pki
      SSHKey.generate(
        type: 'RSA',
        bits: 4096
      )
    end

    def create_key_pair
      secret = create_key_pair_resource
      return if resource_exists?(secret)

      new_key = generate_pki
      secret.data = {
        private_key: Base64.encode64(new_key.private_key).delete("\n"),
        public_key: Base64.encode64(new_key.ssh_public_key).delete("\n")
      }
      deploy_resource(K8sHelpers::GITOPS_NAMESPACE, secret)
    end

    def public_key
      return nil if @client.nil?

      secret = create_key_pair_resource
      begin
        secret = @client.get_resource(secret)
        Base64.decode64(secret.data.public_key)
      rescue K8s::Error::NotFound
        return nil
      end
    end

    def gitop_resources
      api = @client.api('io.wunderwander/v1')
      api.resource('gitops', namespace: K8sHelpers::GITOPS_NAMESPACE).list
    end

    def deploy_resource(namespace, resource)
      resource.metadata.namespace = namespace if namespace
      begin
        available = @client.get_resource(resource)
        @client.update_resource(resource) if available
      rescue K8s::Error::Invalid
       # @logger.info "Can't update resource #{resource}"
      rescue K8s::Error::NotFound
        @client.create_resource(resource)
      end
    end

    def create_namespace(namespace)
      return if namespace.nil?

      namespace_resource = K8s::Resource.new(
        apiVersion: 'v1',
        kind: 'Namespace',
        metadata: {
          name: namespace
        }
      )
      deploy_resource(nil, namespace_resource)
    end
  end
end
