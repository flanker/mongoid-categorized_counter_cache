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
          if record = __send__(relation_name)
            _original_cache_column, current_cache_column = cateogrized_cached_counter_column_names(category_field_name, cache_column_base, options)

            record[current_cache_column] = (record[current_cache_column] || 0) + 1

            if record.persisted?
              record.class.with(record.persistence_context) do |_class|
                _class.increment_counter(current_cache_column, record._id) if current_cache_column.present?
              end
              record.remove_change(current_cache_column)
            end
          end
        end

        after_update do
          foreign_key = relation.foreign_key

          if record = __send__(relation_name)
            if attribute_changed?(foreign_key)
              original, current = attribute_change(foreign_key)
              original_cache_column, current_cache_column = cateogrized_cached_counter_column_names(category_field_name, cache_column_base, options)

              unless original.nil?
                record.class.with(persistence_context) do |_class|
                  _class.decrement_counter(original_cache_column, original) if original_cache_column.present?
                end
              end

              unless current.nil?
                record[current_cache_column] = (record[current_cache_column] || 0) + 1
                record.class.with(record.persistence_context) do |_class|
                  _class.increment_counter(current_cache_column, current) if record.persisted? && current_cache_column.present?
                end
              end
            else attribute_changed?(category_field_name)
              original_cache_column, current_cache_column = cateogrized_cached_counter_column_names(category_field_name, cache_column_base, options)

              record[original_cache_column] = (record[original_cache_column] || 0) - 1 if original_cache_column.present?
              record[current_cache_column] = (record[current_cache_column] || 0) + 1 if current_cache_column.present?
              record.class.with(record.persistence_context) do |_class|
                if record.persisted?
                  _class.decrement_counter(original_cache_column, record) if original_cache_column.present?
                  _class.increment_counter(current_cache_column, record) if current_cache_column.present?
                end
              end
            end
          elsif attribute_changed?(foreign_key)
            original, current = attribute_change(foreign_key)
            original_cache_column, _current_cache_column = cateogrized_cached_counter_column_names(category_field_name, cache_column_base, options)

            unless original.nil?
              relation.klass.with(persistence_context) do |_class|
                _class.decrement_counter(original_cache_column, original) if original_cache_column.present?
              end
            end
          end
        end

        before_destroy do
          if record = __send__(relation_name)
            original_cache_column, _current_cache_column = cateogrized_cached_counter_column_names(category_field_name, cache_column_base, options)

            record[original_cache_column] = (record[original_cache_column] || 0) - 1 unless record.frozen? || original_cache_column.empty?
            if record.persisted?
              record.class.with(record.persistence_context) do |_class|
                _class.decrement_counter(original_cache_column, record._id) if original_cache_column.present?
              end
              record.remove_change(original_cache_column)
            end
          end
        end

      end
    end

    def cateogrized_cached_counter_column_names(category_field_name, cache_column_base, options)
      if attribute_changed?(category_field_name)
        original_category, current_category = attribute_change(category_field_name)
        original_cache_column = cache_column_name cache_column_base, original_category, options if original_category.present?
        current_cache_column = cache_column_name cache_column_base, current_category, options if current_category.present?
      else
        category = self.send category_field_name
        current_cache_column = cache_column_name cache_column_base, category, options
        original_cache_column = current_cache_column
      end
      return [original_cache_column, current_cache_column]
    end

    def cache_column_name cache_column_base, category, options
      options[:prefix] ? "#{category}_#{cache_column_base}_count" : "#{cache_column_base}_#{category}_count"
    end

  end
end
