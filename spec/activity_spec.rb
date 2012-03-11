require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Joyce::Activity do
  describe "validation" do
    context "with missing parameters" do
      [
        {:verb => "fooled"},
        {:actor => Thing.create(:name => "Ulysses")}
      ].each do |params|
        context "with #{params}" do
          it { Joyce::Activity.new(params).should_not be_valid }
        end
      end
    end
  end
end