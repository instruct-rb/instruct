require 'psych'
require 'yaml'

module Instruct::Serializer

    class << self
      def dump(transcript_or_completion)
        YAML.dump(transcript_or_completion)
      end

      def load(transcript_or_completion_bytes, permitted_classes: [])
        permitted_classes = permitted_classes + @@permitted_classes.dup
        # permitted_classes += PERMITTED_CLASSES
        # all instruct classes at load time should be permitted
        doc = Psych.parse(transcript_or_completion_bytes)
        transform_ast(doc, permitted_classes)
        doc.to_ruby
      end

      def add_permitted_class(klass)
        @@permitted_classes << klass
      end

      private

      @@permitted_classes =  Instruct.constants.map { |const| Instruct.const_get(const) }.select { |const| const.is_a?(Class) }

      def transform_ast(node, permitted_classes)
        if node.is_a?(Psych::Nodes::Mapping) && node.tag&.start_with?('!ruby/instruct:')
          class_id, version = node.tag.split(':').last.split('@')
          klass = ClassRegistry.lookup(class_id)
          node.tag = "!ruby/object:#{klass}"
          # add a version integer to the object
          version_node_key = Psych::Nodes::Scalar.new('version')
          version_node_value = Psych::Nodes::Scalar.new(version.to_s) # Ensure it's an integer
          node.children << version_node_key
          node.children << version_node_value
          if klass == nil
            raise ArgumentError, "Class #{klass} not found in serialization registry"
          end
        elsif node.is_a?(Psych::Nodes::Mapping) && node.tag&.start_with?('!ruby/object:')
          klass = node.tag.sub('!ruby/object:', '')
          if !permitted_classes.include?(klass)
            raise ArgumentError, "Class #{klass} not permitted"
          end
        end

        if node.respond_to?(:children) && node.children
          node.children.each { |child| transform_ast(child, permitted_classes) }
        end
      end
    end




    module ClassRegistry
      @registry = {}
      def self.register(class_id, current_klass)
        @registry[class_id.to_s] = current_klass
      end

      def self.lookup(class_id)
        @registry[class_id.to_s]
      end

    end


end
