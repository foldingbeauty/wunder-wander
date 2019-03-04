require './lib/log_helpers.rb'

RSpec.describe LogHelpers do
  subject { LogHelpers.create_logger }
  it "return a new Logger" do
      expect(subject).to match Logger
  end
end