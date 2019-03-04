# frozen_string_literal: true

# handeling generic stuff
module WunderWanderHelpers
  VERSION = '0.1.4'
  BASE_IMAGE = 'foldingbeauty/wunderwander-gitops'
  IMAGE = "#{BASE_IMAGE}:#{VERSION}"
  DEFAULT_PULL_FREQENCY = 10
end
