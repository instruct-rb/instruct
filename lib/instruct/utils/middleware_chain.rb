module Instruct
  # Handles executing middleware chain. We use this class to coordinate as it allows us to
  # make modifications inbetween middleware
  class MiddlewareChain
    # @param middlewares [Array<#call(req, _next::), MiddlewareChain>] An array of middleware objects. This can be a mix of classes, instances, procs, or other middleware chains.
    def initialize(middlewares:)
      raise ArgumentError, "Middlewares must be an array, not #{middlewares.inspect}" unless middlewares.is_a?(Array)
      @middlewares = middlewares
    end

    # Duplicates the middleware chain.
    def dup
      self.class.new(middlewares: @middlewares.dup)
    end

    # Executes the middleware chain with the given request object.
    def execute(req)
      raise RuntimeError, "Cannot call execute_* recursively or concurrently" if @stack_ptr
      @stack_ptr = -1
      resp = call(req)
      @stack_ptr = nil
      resp
    end

    # @api private
    # Don't use. This is internally used to call the _next: middleware in the chain.
    def call(req)
      raise RuntimeError, "Cannot use .call directly, use .execute" if @stack_ptr.nil?

      @stack_ptr += 1

      if @stack_ptr >= @middlewares.size
        raise RuntimeError, "Middleware chain exhausted, last object should not have called _next:"
      end

      middleware = @middlewares[@stack_ptr]

      if middleware.is_a?(Class) && !middleware.respond_to?(:call)
        middleware = middleware.new
      end

      middleware.is_a?(Instruct::MiddlewareChain) ? middleware.execute(req) : middleware.call(req, _next: self)
    end

  end
end
