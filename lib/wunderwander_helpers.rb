# frozen_string_literal: true

# handeling generic stuff
module WunderWanderHelpers
  VERSION = '0.1.4-dev'
  BASE_IMAGE = 'foldingbeauty/wunderwander-gitops'
  IMAGE = "#{BASE_IMAGE}:#{VERSION}" || ENV['GITOPS_IMAGE']
  DEFAULT_PULL_FREQENCY = 10
end
