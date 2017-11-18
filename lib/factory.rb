# frozen_string_literal: true

class Factory
  def self.new(*arguments, &block)
    name = arguments.shift if arguments.first.is_a? String

    clazz = Class.new do
      attr_accessor *arguments

      define_method :initialize do |*params|
        raise ArgumentError, 'Excess arguments' if params.size > arguments.size

        arguments.each_with_index do |_value, index|
          instance_variable_set("@#{_value}", params[index])
        end
      end

      def to_s
        to_a << self.class
      end

      def ==(other)
        to_s == other.to_s
      end

      def [](param)
        attr_name = if param.class.superclass == Numeric
                      raise IndexError unless instance_variables[param.floor]
                      instance_variables[param.floor]
                    else
                      raise NameError unless instance_variable_get("@#{param}")
                      "@#{param}"
        end
        instance_variable_get(attr_name)
      end

      def []=(attr_name, attr_value)
        if attr_name.is_a? Integer
          raise IndexError unless instance_variables[attr_name]
        end
        raise NameError unless instance_variable_get("@#{attr_name}")
        instance_variable_set("@#{attr_name}", attr_value)
      end

      def size
        members.count
      end

      define_method :members do
        arguments
      end

      def each(&block)
        instance_variables_values.each(&block)
      end

      def each_pair
        members.each do |attr_name|
          yield attr_name, send(attr_name)
        end
      end

      def values_at(*indexes)
        indexes.map do |index|
          raise IndexError unless instance_variables[index]
          to_a[index]
        end
      end

      def select(&block)
        to_a.select(&block)
      end

      def dig(*key)
        to_h.dig(*key)
      end

      def to_h
        members.each_with_object({}) do |name, hash|
          hash[name] = self[name]
        end
      end

      def instance_variables_values
        instance_variables.map do |var|
          instance_variable_get(var)
        end
      end

      alias_method :to_a, :instance_variables_values
      alias_method :length, :size
      protected :instance_variables_values
      class_eval(&block) if block_given?
    end
    name ? const_set(name, clazz) : clazz
  end
end
