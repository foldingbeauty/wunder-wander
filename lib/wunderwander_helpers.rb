# handeling generic stuff
module WunderWanderHelpers
  VERSION = '0.1.4-dev'.freeze
  BASE_IMAGE = 'foldingbeauty/wunderwander-gitops'.freeze
  IMAGE = "#{BASE_IMAGE}:#{VERSION}".freeze
  DEFAULT_PULL_FREQENCY = 10
end
