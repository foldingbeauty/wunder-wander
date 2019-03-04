require './lib/wunderwander/gitops_worker.rb'

RSpec.describe WunderWander::GitopsWorker do

  subject { described_class.new() }

  it "initialize a git client" do 
    parsed_git = subject.initialize_git
    expect(parsed_git.user).to eq 'git'
    expect(parsed_git.host).to eq 'github.com'
  end
end