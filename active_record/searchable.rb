require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    cols_and_q_marks = params.keys.map(&:to_s).join(" = ? AND ") + " = ?"
    p params.values
    object_params = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{cols_and_q_marks}
    SQL

    self.parse_all(object_params)
  end
end
