# frozen_string_literal: true

class Factory
  def self.new(*arguments, &block)
    name = arguments.shift if arguments.first.is_a? String

    instance = Class.new do
      attr_accessor *arguments

      define_method :initialize do |*params|
        raise ArgumentError, 'Excess arguments' if params.size > arguments.size

        params.each_with_index do |value, index|
          instance_variable_set("@#{arguments[index]}", value)
        end
      end

      def ==(other)
        instance_variables_values == other.instance_variables_values
      end

      def [](param)

        instance_variable_name = if param.is_a? Integer
                instance_variables[param]
              else
                "@#{param}"
              end
        instance_variable_get(instance_variable_name)
      end

      def []=(param, value)
        instance_variable_set("@#{param}", value)
      end

      def size
        instance_variables.count
      end

      def members
        instance_variables.map { |var| var.to_s.tr('@', '').to_sym }
      end

      def each(&block)
        instance_variables_values.each(&block)
      end

      def each_pair(&block)
        Hash[members.zip(instance_variables_values)].each(&block)
      end

      def values_at(*indexes)
        indexes.map { |index| to_a[index] }
      end

      def select(&block)
        to_a.keep_if(&block)
      end

      def dig(*params)
        params.inject(self) do |result, param|
          break if result.class == NilClass
          result[param]
        end
      end

      private
      def instance_variables_values
        instance_variables.map do |var|
          instance_variable_get(var)
        end
      end

      alias_method :to_a, :instance_variables_values
      alias_method :length, :size
      class_eval(&block) if block_given?
    end

    name ? const_set(name, instance) : instance
  end
end
