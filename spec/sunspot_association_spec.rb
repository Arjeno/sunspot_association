require 'spec_helper'

describe SunspotAssociation do

  with_model :User do
    table do |t|
      t.belongs_to :company
      t.string :name
      t.timestamps
    end

    model do
      belongs_to :company
    end
  end

  with_model :Order do
    table do |t|
      t.belongs_to :company
      t.string :number
      t.timestamps
    end

    model do
      belongs_to :company
    end
  end

  with_model :Company do
    table do |t|
      t.string :name
      t.string :number
      t.timestamps
    end

    model do
      has_many :orders
      has_many :users
      sunspot_associate :orders
    end
  end

  let(:company) { Company.create({ :name => 'Company name', :number => '1' }) }
  let(:order) { Order.create({ :number => '1', :company => company }) }
  let(:user) { User.create({ :name => 'John Doe', :company => company }) }

  before(:each) do
    Company.sunspot_associate :orders, :fields => :name
    Company.sunspot_associate :users, :on_create => true
  end

  after(:each) do
    Company.reset_sunspot_associations!
  end

  describe :sunspot_association_configuration do

    it do
      Company.sunspot_association_configuration.should == {
        :orders => { :fields => [:name] },
        :users  => { :fields => [], :on_create => true }
      }
    end

    context 'with multiple objects' do

      before(:each) do
        Company.sunspot_associate :orders, :users, :fields => :name, :on_create => true
      end

      it do
        Company.sunspot_association_configuration.should == {
          :orders => { :fields => [:name], :on_create => true },
          :users  => { :fields => [:name], :on_create => true },
        }
      end

    end

  end

  describe :reindex_sunspot_association? do

    subject { company }

    context 'without changes' do

      it { company.reindex_sunspot_association?(:orders).should be_false }
      it { company.reindex_sunspot_association?(:users).should be_false }

    end

    context 'with changes' do

      before(:each) { company.name = 'Name change' }

      it { company.reindex_sunspot_association?(:orders).should be_true }
      it { company.reindex_sunspot_association?(:users).should be_true }

    end

    context 'with any change' do

      before(:each) { company.number = '5' }

      it { company.reindex_sunspot_association?(:orders).should be_false }
      it { company.reindex_sunspot_association?(:users).should be_true }

    end

  end

  describe :callbacks do

    context :after_create do

      let(:company) { Company.new }
      after(:each) { company.save }

      it do
        company.should_not_receive(:reindex_sunspot_association!).with(:orders)
        company.should_receive(:reindex_sunspot_association!).with(:users)
      end

    end

    context :after_update do

      context 'with tracked change' do

        after(:each) { company.update_attributes({ :name => 'name change' }) }

        it do
          company.should_receive(:reindex_sunspot_association!).with(:orders)
          company.should_receive(:reindex_sunspot_association!).with(:users)
        end

      end

      context 'with untracked change' do

        after(:each) { company.update_attributes({ :number => '5' }) }

        it do
          company.should_not_receive(:reindex_sunspot_association!).with(:orders)
          company.should_receive(:reindex_sunspot_association!).with(:users)
        end

      end

    end

    context :after_destroy do

      after(:each) { company.destroy }

      it do
        company.should_receive(:reindex_sunspot_association!).with(:orders)
        company.should_receive(:reindex_sunspot_association!).with(:users)
      end

    end

  end

end
