require 'spec_helper'

describe SunspotAssociation::Searchable do

  ## Shared examples

  shared_examples_for 'a searchable field' do |searchable_field, type, stored|
    stored ||= false

    let(:field) { fetch_fields(searchable_field, model) }
    let(:data) { field.build }

    subject { field }

    it { should be_present }
    it { data.instance_variable_get(:@stored).should == stored }
    it { data.type.class.should == type } if type
  end

  ## Methods

  def fetch_fields(name, model)
    fields = Sunspot::Setup.for(model).field_factories
    fields += Sunspot::Setup.for(model).text_field_factories
    fields += Sunspot::Setup.for(model).dynamic_field_factories

    fields.flatten!

    found_fields = fields.collect do |f|
      f if f.name == name
    end.compact

    found_fields.count > 1 ? found_fields : found_fields.first
  end

  ## Models

  with_model :User do
    table do |t|
      t.belongs_to :company
      t.string :name
      t.timestamps
    end

    model do
      include Sunspot::Rails::Searchable
      belongs_to :company
    end
  end

  with_model :Company do
    table do |t|
      t.string :name
      t.string :phone
      t.timestamps
    end

    model do
      has_many :users
    end
  end

  describe :associate do

    describe :setup_association_reindex do

      after(:each) do
        Company.reset_sunspot_associations!
      end

      subject { Company.sunspot_association_configuration }

      describe 'default' do

        before(:each) do
          User.searchable do
            associate :text, :company, :name
          end
        end

        it { should == { :users => { :fields => [:name] } } }

      end

      describe :inverse_name do

        before(:each) do
          User.searchable do
            associate :text, :company, :name, :inverse_name => :company_users
          end
        end

        it { should == { :company_users => { :fields => [:name] } } }

      end

      describe :index_on_change do

        context 'with true' do

          before(:each) do
            User.searchable do
              associate :text, :company, :name, :index_on_change => true
            end
          end

          it { should == { :users => { :fields => [] } } }

        end

        context 'with false' do

          before(:each) do
            User.searchable do
              associate :text, :company, :name, :index_on_change => false
            end
          end

          it { should == {} }

        end

        context 'with array' do

          before(:each) do
            User.searchable do
              associate :text, :company, :pretty_address, :index_on_change => [:address]
            end
          end

          it { should == { :users => { :fields => [:address] } } }

        end

      end

    end

    describe :sunspot_settings do

      let(:model) { User }

      describe :text do

        before(:each) do
          User.searchable do
            associate :text, :company, :name
          end
        end

        it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::TextType

        it do
          Company.sunspot_association_configuration.should == {
            :users => { :fields => [:name] }
          }
        end

        context 'with multiple' do

          describe 'in one call' do

            before(:each) do
              User.searchable do
                associate :text, :company, :name, :phone
              end
            end

            it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::TextType
            it_should_behave_like 'a searchable field', :company_phone, Sunspot::Type::TextType

            it do
              Company.sunspot_association_configuration.should == {
                :users => { :fields => [:name, :phone] }
              }
            end

          end

          describe 'in multiple calls' do

            before(:each) do
              User.searchable do
                associate :text, :company, :name
                associate :text, :company, :phone
              end
            end

            it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::TextType
            it_should_behave_like 'a searchable field', :company_phone, Sunspot::Type::TextType

            it do
              Company.sunspot_association_configuration.should == {
                :users => { :fields => [:name, :phone] }
              }
            end

          end

        end

      end

      describe :string do

        before(:each) do
          User.searchable do
            associate :string, :company, :name
          end
        end

        it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::StringType

        context 'with stored' do

          before(:each) do
            User.searchable do
              associate :string, :company, :name, :stored => true
            end
          end

          it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::StringType, true

        end

        context 'with multiple' do

          describe 'in one call' do

            before(:each) do
              User.searchable do
                associate :string, :company, :name, :phone
              end
            end

            it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::StringType
            it_should_behave_like 'a searchable field', :company_phone, Sunspot::Type::StringType

          end

          describe 'in multiple calls' do

            before(:each) do
              User.searchable do
                associate :string, :company, :name
                associate :string, :company, :phone
              end
            end

            it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::StringType
            it_should_behave_like 'a searchable field', :company_phone, Sunspot::Type::StringType

          end

        end

      end

    end

    context 'when declaring searchable before the association' do

      with_model :Order do
        table do |t|
          t.belongs_to :user
          t.timestamps
        end

        model do
          include Sunspot::Rails::Searchable
          searchable do
            associate :text, :user, :name
          end
          belongs_to :user
        end
      end

      subject { User.sunspot_association_configuration }

      it { should == { :orders => { :fields => [:name] } } }

    end

  end

end
