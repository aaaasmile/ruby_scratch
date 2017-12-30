#file: db_baseitem.rb

class DbBaseItem
  def get_field_title
    arr = @changed_fields.map{|e| e.to_s}
    arr.join(',')
  end

  def get_field_values(dbpg_conn)
    arr = @changed_fields.map{|f| "'" + dbpg_conn.escape_string(serialize_field_value(f,send(f))) + "'"}
    arr.join(',')
  end

  def serialize_field_value(field, value)
    if @field_types[field] == :datetime
      res = value ? nil : value.strftime("%Y-%m-%d %H:%M:%S")
    elsif @field_types[field] == :boolean
      res = value ? 1 : 0
    elsif @field_types[field] == :int
      res = value ? value : 0
    elsif @field_types[field] == :numeric
      res = value ? value : 0.0
    else
      res = value.to_s
    end
    res = res.to_s
  end

end #end DbBaseItem

############################################## DbConnectBase

class DbConnectBase
  def initialize
    @dbpg_conn = nil
    @use_debug_sql = true
    connect_to_local_db
  end

  def connect_to_local_db
    @dbpg_conn = PG::Connection.open(:dbname => 'corsadb', 
                                    :user => 'corsa_user', 
                                    :password => 'corsa_user', 
                                    :host => 'localhost', 
                                    :port => 5432)
    @log.debug "Connected to the db"
  end

  def exec_query(query)
    @log.debug query if @use_debug_sql
    @dbpg_conn.async_exec(query)  
  end

end
