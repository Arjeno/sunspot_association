require 'active_record'

module SunspotAssociation
  module Model

    extend ActiveSupport::Concern

    included do

      ## Attributes

      cattr_accessor :sunspot_association_configuration
      cattr_accessor :sunspot_association_callbacks

    end

    module ClassMethods

      def sunspot_associate?
        self.sunspot_association_configuration != {}
      end

      # Reindex associations when a model changes
      #
      # Options:
      #
      # :fields
      # => Field(s) to watch for changes
      #
      # :on_create
      # => Specifies if it should reindex associations when a record is created
      #
      # Examples:
      #
      # => sunspot_associate :orders, :fields => :name
      # => sunspot_associate :orders, :users, :fields => [:name, :phone], :on_create => true
      #
      def sunspot_associate(*args)
        options = args.extract_options!
        fields  = options.delete(:fields)

        self.sunspot_association_configuration ||= {}

        args.each do |object|
          default = { :fields => [] }
          config  = self.sunspot_association_configuration[object] || default

          # Fields
          config[:fields] += Array(fields)
          config[:fields].compact!
          config[:fields].uniq!

          config.merge!(options)

          self.sunspot_association_configuration[object] = config
        end

        sunspot_association_callbacks!
      end

      def sunspot_association_callbacks!
        return true if self.sunspot_association_callbacks == true

        after_create  Proc.new { |o| o.reindex_sunspot_associations!(:create) }
        after_update  Proc.new { |o| o.reindex_sunspot_associations!(:update) }
        after_destroy Proc.new { |o| o.reindex_sunspot_associations!(:destroy) }

        self.sunspot_association_callbacks = true
      end

      def reset_sunspot_associations!
        self.sunspot_association_configuration = {}
        self.sunspot_association_callbacks = false
      end

    end

    # Main callback method, checks if it should reindex an association
    def reindex_sunspot_associations!(event)
      self.class.sunspot_association_configuration.each do |object, config|
        case event
        when :create
          reindex_sunspot_association!(object) if config[:on_create]
        when :update
          reindex_sunspot_association!(object) if reindex_sunspot_association?(object)
        when :destroy
          reindex_sunspot_association!(object)
        end
      end
    end

    # Checks if an association should be reindexed
    # => reindex_sunspot_association?(:orders) => true
    def reindex_sunspot_association?(object)
      if (config = (self.class.sunspot_association_configuration || {})[object]).present?
        if config[:fields].present?
          return ! (changed & (config[:fields] || []).map(&:to_s)).empty?
        else
          return changed.any?
        end
      end

      false
    end

    # Reindexes an association using Sunspot.index
    def reindex_sunspot_association!(object)
      return false unless self.class.sunspot_associate?
      return false unless self.respond_to?(object)

      Sunspot.index self.send(object)
    end

  end
end

ActiveRecord::Base.send(:include, SunspotAssociation::Model)