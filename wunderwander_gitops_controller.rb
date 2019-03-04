# frozen_string_literal: true
$LOAD_PATH << '.'
require 'lib/wunderwander/gitops_controller.rb'

WunderWander::GitopsController.new.start_controller
