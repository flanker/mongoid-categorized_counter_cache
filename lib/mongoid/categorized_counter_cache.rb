require 'mongoid/categorized_counter_cache/version'

module Mongoid
  module CategorizedCounterCache

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def categorized_counter_cache relation_name, options = {}
        relation = self.relations[relation_name.to_s]
        category_field_name = options[:by]
        cache_column_base = relation.inverse_class_name.demodulize.underscore.pluralize

        after_create do
          category = self.send category_field_name
          cache_column = cache_column_name cache_column_base, category, options

          if record = __send__(relation_name)
            record[cache_column] = (record[cache_column] || 0) + 1

            if record.persisted?
              record.class.with(record.persistence_context) do |_class|
                _class.increment_counter(cache_column, record._id)
              end
              record.remove_change(cache_column)
            end
          end
        end

        after_update do
          foreign_key = relation.foreign_key
          category = self.send category_field_name
          cache_column = cache_column_name cache_column_base, category, options

          if record = __send__(relation_name)
            if attribute_changed?(foreign_key)
              original, current = attribute_change(foreign_key)

              unless original.nil?
                record.class.with(persistence_context) do |_class|
                  _class.decrement_counter(cache_column, original)
                end
              end

              unless current.nil?
                record[cache_column] = (record[cache_column] || 0) + 1
                record.class.with(record.persistence_context) do |_class|
                  _class.increment_counter(cache_column, current) if record.persisted?
                end
              end
            end
          elsif attribute_changed?(foreign_key)
            original, current = attribute_change(foreign_key)

            unless original.nil?
              relation.klass.with(persistence_context) do |_class|
                _class.decrement_counter(cache_column, original)
              end
            end
          end
        end

        before_destroy do
          if record = __send__(relation_name)
            category = self.send category_field_name
            cache_column = cache_column_name cache_column_base, category, options
            record[cache_column] = (record[cache_column] || 0) - 1 unless record.frozen?

            if record.persisted?
              record.class.with(record.persistence_context) do |_class|
                _class.decrement_counter(cache_column, record._id)
              end
              record.remove_change(cache_column)
            end
          end
        end

      end
    end

    def cache_column_name cache_column_base, category, options
      options[:prefix] ? "#{category}_#{cache_column_base}_count" : "#{cache_column_base}_#{category}_count"
    end

  end
end
