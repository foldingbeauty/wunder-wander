# frozen_string_literal: true

# handeling generic stuff
module WunderWanderHelpers
  VERSION = '0.1.4'
  BASE_IMAGE = 'foldingbeauty/wunderwander-gitops'
  IMAGE = ENV['GITOPS_IMAGE'] || "#{BASE_IMAGE}:#{VERSION}"
  DEFAULT_PULL_FREQENCY = 10
  GITOPS_NAMESPACE = ENV['GITOPS_NAMESPACE'] || 'wunderwander-gitops'
end
