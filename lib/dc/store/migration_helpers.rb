module DC
  module Store
    
    # Helpers for migrations and schema.rb, adding foreign key support.
    module MigrationHelpers
      
      def foreign_key(from_table, to_table)
        from_column ||= "#{to_table.singularize}_id"
        execute %{
          alter table #{from_table}
          add constraint fk_#{from_column}
          foreign key (#{from_column})
          references #{to_table} (id)
        }
      end
      
      def drop_foreign_key(from_table, to_table)
        constraint_name = "fk_#{to_table.singularize}_id"
        execute "alter table #{from_table} drop foreign key #{constraint_name}"
        execute "alter table #{from_table} drop key #{constraint_name}"
      end
      
      def disable_foreign_keys
        execute 'set foreign_key_checks=0'
      end
      
      def enable_foreign_keys
        execute 'set foreign_key_checks=1'
      end
      
    end
    
  end
end