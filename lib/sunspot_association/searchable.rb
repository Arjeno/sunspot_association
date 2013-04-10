require 'sunspot/rails'

module SunspotAssociation
  module Searchable

    extend ActiveSupport::Concern

    # Index association fields
    #
    # Examples:
    #
    # => associate :text, :company, :name
    # => associate :text, :company, :name, :phone
    #
    def associate(type, association_name, *fields)
      options = fields.extract_options!

      fields.each do |field|
        name = [association_name, field].join('_')
        self.send(type, name, options) do
          self.send(association_name).send(field)
        end
      end
    end

  end
end

Sunspot::DSL::Fields.send(:include, SunspotAssociation::Searchable)
