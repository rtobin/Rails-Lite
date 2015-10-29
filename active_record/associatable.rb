require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options.each do |key, val|
      self.send("#{key}=", val)
    end
    @foreign_key ||= "#{name}_id".to_sym
    @class_name ||= name.camelcase
    @primary_key ||= :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options.each do |key, val|
      self.send("#{key}=", val)
    end
    @foreign_key ||= "#{self_class_name.downcase}_id".to_sym
    @class_name ||= name.singularize.camelcase
    @primary_key ||= :id
  end
end

module Associatable
  def belongs_to(name, options_hash = {})
    options = BelongsToOptions.new(name.to_s, options_hash)
    define_method(name) do
      id = send(options.foreign_key)
      options.model_class.where(options.primary_key => id).first
    end

    assoc_options[name] = options
  end

  def has_many(name, options_hash = {})
    options = HasManyOptions.new(name.to_s, self.name, options_hash)
    define_method(name) do
      id = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => id)
    end

    assoc_options[name] = options
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_tbl = through_options.table_name
      through_p_key = through_options.primary_key
      through_f_key = through_options.foreign_key

      source_options = through_options.model_class.assoc_options[source_name]
      source_tbl = source_options.table_name
      source_p_key = source_options.primary_key
      source_f_key = source_options.foreign_key

      id = self.send(through_f_key)
      stuff = DBConnection.execute(<<-SQL, id )
        SELECT
          #{source_tbl}.*
        FROM
          #{through_tbl}
        JOIN
          #{source_tbl}
        ON
          #{through_tbl}.#{source_f_key} = #{source_tbl}.#{source_p_key}
        WHERE
          #{through_tbl}.#{through_p_key} = ?
        ;
      SQL

      source_options.model_class.parse_all(stuff).first
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end
