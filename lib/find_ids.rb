module ActiveRecordExtensions
  module FindIds
    def find_ids(options = {})
      find_column_values(primary_key, options)
    end
    
    def find_column_values(column_name, options = {})
      # Get the results as an array of tiny hashes { "id" => "1" } and flatten them out to just the ids
      column_name_s = column_name.to_s
      find_multiple_column_values(column_name, options).map{|record| record[column_name_s]}
    end
    
    def find_set_ids(options = {})
      find_set_column_values(primary_key, options)
    end

    def find_set_column_values(column_name, options = {})
      Set.new(find_column_values(column_name, options))
    end
    
    def find_multiple_column_values(*column_names)
      options = column_names.extract_options!
      
      distinct = "distinct" if options.delete(:distinct)
      select_for_columns = column_names.map{|column_name| "#{distinct} #{quoted_table_name}.`#{column_name}`"}.join(', ')
      sql = construct_finder_sql(options.merge( :select => select_for_columns ))

      array_of_hashes = connection.select_all(sql)
      array_of_hashes.each do |columns_values_hash|
        columns_values_hash.each do |k,v|
          columns_values_hash[k] = self.columns_hash[k].type_cast(v)
        end
      end
    end
  end
end

ActiveRecord::Base.extend ActiveRecordExtensions::FindIds