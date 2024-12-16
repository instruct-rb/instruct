require "rails"

module Instruct::Rails
  class Railtie < Rails::Railtie
    initializer "instruct.active_job.custom_serializers" do
      require_relative "rails/active_job_object_serializer"
      config.after_initialize do
        ActiveJob::Serializers.add_serializers(Instruct::Rails::ActiveJobObjectSerializer)
      end
    end
  end
end
