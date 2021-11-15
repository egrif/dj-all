require 'open3'

RSpec.describe "dj-all cli" do
  context "when receiving bad params" do

    it "requires -a (--application) to be defined" do
      stderrout, _status = Open3.capture2e("bin/dj-all -e dev,uat,use1 -v *V* 2>&1")
      expect(stderrout.strip).to match(/^ERROR\:.*application.*/i)
    end

    it "requires -v (--variable) to be defined" do
      stderrout, _status = Open3.capture2e("bin/dj-all -a greenhouse -e dev,uat,use1 2>&1")
      expect(stderrout.strip).to match(/^ERROR\:.*variable.*/i)
    end

    it "requires the group to be defined when using -g (group)" do
      stderrout, _status = Open3.capture2e("bin/dj-all -a greenhouse -g krazygroupnamethatnoonewouldeveruse 2>&1")
      expect(stderrout.strip).to match(/^ERROR\:.*group.*/i)
    end

    it "fails if missing value is ambiguous" do
      stderrout, _status = Open3.capture2e("bin/dj-all -a greenhouse -r use1 -s dev -e dev,uat -v *V* 2>&1")
      expect(stderrout.strip).to match(/^ERROR\:.*ambiguous.*/i)
    end

    it "fails if not enough environment parts are specified" do
      stderrout, _status = Open3.capture2e("bin/dj-all -a greenhouse -r use1 -e dev -v *V* 2>&1")
      expect(stderrout.strip).to match(/^ERROR\:.*parts.*/i)
    end

    it "fails if missing value is ambiguous" do
      stderrout, _status = Open3.capture2e("bin/dj-all -a greenhouse -r use1 -s dev -e dev,uat -v *V* 2>&1")
      expect(stderrout.strip).to match(/^ERROR\:.*ambiguous.*/i)
    end
  end
end
