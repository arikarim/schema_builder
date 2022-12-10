# json_schema.rb
require 'json'

# Define the JSONSchema class
class JSONSchema
  # Initialize the class with the object and included fields
  def initialize(object, included)
    @object = object
    @included = included
  end

  # Generate the schema for the object and included fields
  def generate
    # Set the type of the schema to "object"
    schema = { type: 'object' }

    # Initialize the "properties" and "required" fields in the schema
    schema[:properties] = {}
    schema[:required] = []

    # Iterate over the attributes and relationships in the object
    (@object[:attributes] || {}).each do |property, value|
      # Add the property to the schema
      schema[:properties][property] = { type: value.class.name.downcase }
    end
    (@object[:relationships] || {}).each do |property, value|
      # Add the property to the schema
      schema[:properties][property] = { type: 'object' }

      # Generate a schema for the related objects using recursion
      if value[:data].is_a?(Array)
        # Nested array - generate a schema for each item in the array
        schema[:properties][property][:type] = 'array'
        schema[:properties][property][:items] = value[:data].map do |item|
          # Find the included object with the matching type and ID
          included_object = @included[item[:type]][item[:id]]

          # Generate a schema for the included object
          JSONSchema.new(included_object, @included).generate
        end
      else
        # Nested object - generate a schema for it
        # Find the included object with the matching type and ID
        included_object = @included[value[:data][:type]][value[:data][:id]]

        # Generate a schema for the included object
        schema[:properties][property][:properties] = JSONSchema.new(included_object, @included).generate
      end

      # Return the generated schema
      schema
    end
  end
end

# # Define the JSONSchema gem module
# module JSONSchema
#   # Define the gem version
#   VERSION = '1.0.0'

#   # Define the gem root directory
#   ROOT_DIR = File.expand_path('../..', __dir__)

#   # Define the gem lib directory
#   LIB_DIR = File.join(ROOT_DIR, 'lib')

#   # Load the JSONSchema class
#   autoload :JSONSchema, File.join(LIB_DIR, 'json_schema')

#   # Define the gem bin directory
#   BIN_DIR = File.join(ROOT_DIR, 'bin')

#   # Load the gem bin files
#   Dir[File.join(BIN_DIR, '*')].each { |f| require f }
# end
