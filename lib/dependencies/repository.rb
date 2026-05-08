# frozen_string_literal: true

module Dependencies
  class Repository
    class << self
      def stack
        @stack ||= []
        @stack
      end

      def push(class_dependencies:)
        stack << class_dependencies
      end

      def pop
        stack.pop
      end
    end
  end
end
