require 'spec/spec_helper'

describe User do
  before :each do
    @key = "user:123"
    @user = {:name => "john"}
  end
  
  describe "user.save" do
    it "should return user" do
      REDIS.should_receive(:set).with(@key, @user.to_json).and_return("OK")

      User.new(@user.merge(:key => @key)).save.should == @user
    end
  end
  
  describe "User.find" do
    it "should find user" do
      REDIS.should_receive(:get).with(@key).and_return(@user.to_json)
      JSON.should_receive(:parse).with(@user.to_json).and_return(@user)

      User.find(@key).should == @user
    end

    it "should return nil if it can't find user" do
      REDIS.should_receive(:get).with(@key).and_return(nil)

      User.find(@key).should == nil
    end
  end
  
  describe "User.update" do
    it "should find user" do
      User.should_receive(:find).with(@key).and_return(@user)
      
      User.update(@key, {}).should == @user
    end

    it "should return nil if it can't find user" do
      User.should_receive(:find).with(@key).and_return(nil)

      User.update(@key, {}).should == nil
    end
    
    it "should create and save a new user merged with hash" do
      hash = {:name => "tom"}
      new_user_hash = @user.merge({:key => @key}).merge(hash)
      new_user = User.new(new_user_hash)
      
      User.should_receive(:find).with(@key).and_return(@user)
      User.should_receive(:new).with(new_user_hash).and_return(new_user)
      new_user.should_receive(:save).and_return(new_user)

      User.update(@key, hash).should == new_user
    end
  end
end