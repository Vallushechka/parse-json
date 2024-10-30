--- get table from json
CREATE OR REPLACE FUNCTION bookings.get_table(json_str jsonb)
RETURNS table (
	tab_name varchar, 
    col_name varchar,
    filter_name varchar
)
AS $$    
DECLARE
	rec record;
	i jsonb;
	filter_final varchar := '1 = 1 ';
	j record;
	index_i integer := 1;
	index_j integer := 1;
	_arr  varchar[];
	_elem varchar; 
	perem text[];
BEGIN
	SELECT table_name, array_to_string(column_name, ', ')::varchar column_names, filterr filter_name 
    INTO rec
    FROM jsonb_to_record(json_str) AS x(table_name varchar, column_name varchar[], filterr jsonb);
    _arr := (select array(select unnest(string_to_array(rec.column_names, ', '))  as columns_fake
                  EXCEPT
                  select column_name 
                  from  information_schema.columns
                  where table_schema = 'bookings'
                  and table_name = table_name));
  FOREACH _elem IN ARRAY _arr
     LOOP 
    perem = array_append(perem, _elem);   
    END LOOP;
    if check_table(rec.table_name) != 0 then
      raise notice 'таблицы % не существует', rec.table_name;
    else
      if check_columns(rec.table_name, rec.column_names) != 0 then
         raise notice 'Колонок % нет в таблице', perem;
      else
        FOR i IN SELECT * FROM jsonb_array_elements(rec.filter_name::jsonb) loop    
        IF (index_i = 1) THEN
          filter_final := '(';
        ELSE
          filter_final := filter_final || 'OR (';
        END IF;
    	if bookings.check_filter(i) = 1 then
			            FOR j IN SELECT key, value FROM jsonb_each(i) loop
			            IF (index_j = 1) THEN
			                    filter_final := filter_final || '' || j.key || ' = ' || j.value;
			                ELSE 
			                    filter_final := filter_final || ' AND ' || j.key || ' = ' || j.value;
			                END IF;
			                index_j := index_j + 1;
			            END LOOP;  
			          index_j := 1;
			        filter_final := filter_final|| ') ';
			          index_i := index_i + 1;
         else
         	raise notice 'В фильтре несуществующая колонка';
         end if;
        END LOOP;
    
        filter_final := replace(filter_final, '"', '''');
    
        RETURN QUERY 
        SELECT rec.table_name, rec.column_names, filter_final filter_name ;
    end if;
  end if;
END;
$$ LANGUAGE plpgsql;
										

SELECT * 
FROM bookings.get_table(
    '{"table_name": "bookings",
      "column_name": ["book_ref", "book_date"],
      "filterr": [
          {"book_date": "2017-07-05", "total_amount": "102100.00"}, 
          {"book_date": "2017-07-14", "total_amount": "37900.00"}
      ]
    }'::jsonb
);