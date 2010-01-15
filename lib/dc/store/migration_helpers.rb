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

      def add_full_text_index(table, column)
        vector, index, trigger = *full_text_index_names(table, column)
        add_column table, vector, "tsvector"
        execute "create trigger #{trigger} before insert or update on #{table}
          for each row execute procedure tsvector_update_trigger(#{vector}, 'pg_catalog.english', #{column});"
        execute "update #{table} set #{vector} = to_tsvector('pg_catalog.english', #{column});"
        # disabling fastupdate results in slower inserts/updates, but with more compact indexes (tested on PostgreSQL 8.4.2)
        execute "create index #{index} on #{table} using gin(#{vector}) with (fastupdate=off);"
      end

      def remove_full_text_index(table, column)
        vector, index, trigger = *full_text_index_names(table, column)
        execute "drop index #{index};"
        execute "drop trigger #{trigger} on #{table};"
        remove_column table, vector
      end


      private

      def full_text_index_names(table, column)
        vector  = "#{table}_#{column}_vector"
        index   = "#{table}_#{column}_fti"
        trigger = "#{vector}_update"
        [vector, index, trigger]
      end

    end

  end
end
