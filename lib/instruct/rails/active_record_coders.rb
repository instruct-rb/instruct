module Instruct::Rails
  module SerializableModel
    def self.included(base)
      base.extend ClassMethods
    end
    module ClassMethods
      def dump(value)
        Instruct::Serializer.dump(value)
      end
      def load(data)
        Instruct::Serializer.load(data)
      end
    end
  end
end


class Instruct::Prompt
  include Instruct::Rails::SerializableModel
end

class Instruct::Prompt::Completion
  include Instruct::Rails::SerializableModel
end

if defined? Instuct::OpenAI
  class Instruct::OpenAI
    include Instruct::Rails::SerializableModel
  end
end

if defined? Instruct::Anthropic
  class Instruct::Anthropic
    include Instruct::Rails::SerializableModel
  end
end
