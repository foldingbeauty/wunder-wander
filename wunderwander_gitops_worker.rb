# frozen_string_literal: true
$LOAD_PATH << '.'
require 'lib/wunderwander/gitops_worker.rb'

WunderWander::GitopsWorker.new.start_worker
