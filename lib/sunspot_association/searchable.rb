require 'sunspot/rails'

module SunspotAssociation
  module Searchable

    extend ActiveSupport::Concern

    # Index association fields
    #
    # Options:
    #
    # :inverse_name - see `setup_association_reindex`
    #
    # :index_on_change
    # => Boolean or array
    # => Defaults to `fields`
    # => Set to false to disable automatic reindexing
    # => Set to true to reindex for every update
    # => Pass array of fields to specifically watch
    #
    # Examples:
    #
    # => associate :text, :company, :name
    # => associate :text, :company, :name, :phone
    # => associate :text, :company, :name, :phone, :inverse_name => :company_users
    #
    def associate(type, association_name, *fields)
      options = fields.extract_options!

      inverse_name    = options.delete(:inverse_name)
      index_on_change = options.delete(:index_on_change)

      fields.each do |field|
        name = [association_name, field].join('_')
        self.send(type, name, options) do
          self.send(association_name).try(field)
        end
      end

      unless index_on_change == false
        fields_to_watch = fields

        if index_on_change.is_a?(Array)
          fields_to_watch = index_on_change
        elsif index_on_change == true
          fields_to_watch = []
        end

        setup_association_reindex association_name, fields_to_watch, { :inverse_name => inverse_name }
      end
    end

    # Set up automatic reindexing using `sunspot_associate`
    #
    # Options:
    #
    # :inverse_name
    # => Name of inverse association to use, for example :company_users
    #
    # Examples:
    #
    # => setup_association_reindex :company, [:name]
    # => setup_association_reindex :company, [:name], :inverse_name => :company_users
    #
    def setup_association_reindex(association_name, fields, options={})
      searchable_class  = @setup.clazz
      association       = searchable_class.reflect_on_association(association_name)
      association_class = association.try(:klass)
      inverse_name      = options[:inverse_name] || searchable_class.name.pluralize.downcase.to_sym

      return false if association_class.nil?

      association_class.sunspot_associate inverse_name, :fields => fields
    end

  end
end

Sunspot::DSL::Fields.send(:include, SunspotAssociation::Searchable)
