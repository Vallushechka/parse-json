--- function that returns useful json filters
CREATE OR REPLACE FUNCTION bookings.get_filter_json(table_name varchar, column_name varchar, filter_name varchar, limit_ integer, offset_ integer)
RETURNS jsonb
AS $$ 	 
DECLARE 
	rec record;
	json_str jsonb;
	cmd varchar;
	bb1 varchar;
	kk varchar;
	COUNTER NUMERIC;
begin
	execute 'select count(*) over()
				  from ' || table_name ||'
				  where ' || filter_name 
	into COUNTER;
    bb1 := '(select '|| column_name ||'
				  from ' || table_name ||'
				  where ' || filter_name ||'
				  limit '|| limit_ ||' offset '|| offset_ || ') bb' ;
	cmd := 'select jsonb_build_object('''|| table_name ||''', jsonb_agg(row_to_json( bb)), ''total_amount'' , '|| counter ||') as bookings_json 
			from ' || bb1;
	EXECUTE cmd INTO rec;
  	json_str := rec.bookings_json; 
    RETURN json_str;
END;
$$ LANGUAGE plpgsql;

SELECT bookings.get_filter_json(
    'bookings', 
    'book_ref, book_date', 
    '(book_date = ''2017-07-05 03:12:00.000 +0300'') OR 
     (book_date = ''2017-07-14 09:02:00.000 +0300'' AND total_amount = ''37900.00'')', 50, 3
);