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

    describe :sunspot_settings do

      let(:model) { User }

      describe :text do

        before(:each) do
          User.searchable do
            associate :text, :company, :name
          end
        end

        it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::TextType

        context 'with multiple' do

          describe 'in one call' do

            before(:each) do
              User.searchable do
                associate :text, :company, :name, :phone
              end
            end

            it_should_behave_like 'a searchable field', :company_name, Sunspot::Type::TextType
            it_should_behave_like 'a searchable field', :company_phone, Sunspot::Type::TextType

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

  end

end
