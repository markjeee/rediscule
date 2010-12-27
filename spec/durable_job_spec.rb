require File.expand_path('../spec_helper', __FILE__)

context "Jobber" do
  describe "durable job" do
    before(:all) do
      Palmade::Rediscule.configure do
        init SPEC_ROOT, SPEC_ENV
        config "spec/config/jobber.yml"
        map_job "test", :class_name => "TestWorker", :type => "durable"
      end

      @jobber = Palmade::Rediscule.jobber
      @job = @jobber.jobs["test"]
      @job.set_rcache(Palmade::Rediscule::SpecHelper.rcache)
    end

    it "should instantiate a durable job" do
      @job.should be_an_instance_of(Palmade::Rediscule::DurableJob)
    end

    it "should order action" do
      @job.order('test')
      @job.queue.size.should == 1
    end

    it "should reserve one item" do
      unit = @job.reserve
      @job.queue.size.should == 0
      unit.should be_an_instance_of(Palmade::Rediscule::DurableItem)

      payload = unit.get
      payload.should be_an_instance_of(Hash)
      payload['action'].should == 'test'
      payload['origin'].should == 'self'
      unit.done!
    end

    it "should maintain properly" do
      @job.maintain
    end

    it "should instantiate a durable queue" do
      @job.queue.should be_an_instance_of(Palmade::Rediscule::DurableQueue)
    end

    after(:all) do
      @job.destroy
      Palmade::Rediscule.jobber = nil
    end
  end
end