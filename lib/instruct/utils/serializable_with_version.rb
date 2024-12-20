require 'psych'

module Instruct

  module Serializable
    def self.included(base)
      base.extend(ClassMethods)
      base.instance_variable_set(:@_instruct_serializer_version, 1) unless base.instance_variable_defined?(:@_instruct_serializer_version)
      base.instance_variable_set(:@_instruct_serializer_class_id, base.name.hash) unless base.instance_variable_defined?(:@_instruct_serializer_class_id)
      Serializer::ClassRegistry.register(base.instruct_class_id, base)
    end

    module ClassMethods
      def instruct_class_id
        @_instruct_serializer_class_id
      end

      def instruct_class_version
        @_instruct_serializer_version
      end

      def set_instruct_class_id(id)
        @_instruct_serializer_class_id = id
        Serializer::ClassRegistry.register(@_instruct_serializer_class_id, self)
      end

      def set_instruct_class_id_from_original_name(name)
        set_instruct_class_id(name.hash)
      end

      def set_instruct_class_version(v)
        @_instruct_serializer_version = v
      end

      def migrate_data!(data, from:, to:)
        # no-op by default
      end
    end

    def encode_with(coder)
      coder.tag = "!ruby/instruct:#{self.class.instruct_class_id}@#{self.class.instruct_class_version}"
      coder["data"] = instance_vars_to_hash
      # TODO: consider calling the old encode_with method if defined
      # and then this special case can be moved to prompt
      coder["str"] = self.to_s(gen: :nochange) if self.is_a? Prompt
      coder["str"] = self.to_s if coder["str"].nil? && self.is_a?(String)
    end

    def init_with(coder)
      version = coder["version"]
      if self.is_a? String
        replace(coder["str"])
      end
      data = coder["data"] || {}


      if version < self.class.instruct_class_version
        self.class.migrate_data!(data, from: version, to: self.class.instruct_class_version)
      end
      hash_to_instance_vars(data)
    end

    private

    def instance_vars_to_hash
      Hash[instance_variables.map { |ivar| [ivar.to_s.sub('@', ''), instance_variable_get(ivar)] }]
    end

    def hash_to_instance_vars(data)
      data.each { |k, v| instance_variable_set("@#{k}", v) }
    end
  end
end
