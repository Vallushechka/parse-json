--- parse json  
CREATE OR REPLACE FUNCTION bookings.parse_json(input_json jsonb, limit_1 integer, offset_1 integer)
RETURNS jsonb
AS $$    
DECLARE 
    tab_name varchar;
    col_names varchar;
    filter_names varchar;
BEGIN
    SELECT get_table.tab_name, get_table.col_name, get_table.filter_name
    INTO tab_name, col_names, filter_names
    FROM bookings.get_table(input_json);
    RETURN bookings.get_filter_json(tab_name, col_names, filter_names, limit_1, offset_1);
   	
END;
$$ LANGUAGE plpgsql;

SELECT bookings.parse_json(
    '{"table_name": "bookings",
      "column_name": ["book_ref", "book_date"],
      "filterr": [
          
      ]
    }'::jsonb, 50, 1
);