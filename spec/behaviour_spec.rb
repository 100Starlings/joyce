require 'spec_helper'

describe Joyce::Behaviour do
  it "should add acts_as_joyce method" do
    class JoyceTestDummy < ActiveRecord::Base; end
    JoyceTestDummy.methods.should include(:acts_as_joyce)
  end
  
  describe ".acts_as_joyce" do
    it "should add a relationship with streams" do
      Thing.new.methods.should include(:streams)
    end
    
    #it "should add a relationship with activities" do
    #  Thing.new.methods.should include(:activities)
    #end
    
    it "should turn model into an owner" do
      Thing.new.methods.should include(:activity_stream)
    end
  end

end
