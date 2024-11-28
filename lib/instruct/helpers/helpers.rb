module Instruct
  module Helpers
    include Instruct::Helpers::GenHelper
    include Instruct::Helpers::ERBHelper
    include Instruct::Helpers::ModelHelper

    attr_accessor :_instruct_default_model

  end
end
