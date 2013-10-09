module ActiveAdmin
  module Inputs
    class FilterSelectInput < ::Formtastic::Inputs::SelectInput
      include FilterBase

      def input_name
        return method if seems_searchable?

        searchable_method_name.concat multiple? ? '_in' : '_eq'
      end

      def searchable_method_name
        if searchable_has_many_through?
          "#{reflection.through_reflection.name}_#{reflection.foreign_key}"
        else
          polymorphic = reflection && reflection.macro == :belongs_to && reflection.options[:polymorphic]
          key = polymorphic ? nil : reflection.try(:association_primary_key)
          name = [method, key].compact.join('_')
        end
      end

      # Provide the AA translation to the blank input field.
      def include_blank
        I18n.t 'active_admin.any' if super
      end

      # was "#{object_name}[#{association_primary_key}]"
      def input_html_options_name
        "#{object_name}[#{input_name}]"
      end

      # Would normally return true for has_many and HABTM, which would subsequently
      # cause the select field to be multi-select instead of a dropdown.
      def multiple_by_association?
        false
      end

      # Provides an efficient default lookup query if the attribute is a DB column.
      def collection
        if !options[:collection] && column
          pluck_column
        else
          super
        end
      end

      def pluck_column
        klass.reorder("#{method} asc").uniq.pluck method
      end

    end
  end
end
