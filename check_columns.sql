---	columns check
CREATE OR REPLACE FUNCTION bookings.check_columns(table_name1 varchar, column_name1 varchar, schema varchar default 'bookings')
RETURNS int4
AS $$
declare
	counter_col varchar;
	rec int4;
	index_col int4;
begin
	with columns_fake as(select unnest(string_to_array(column_name1, ', ')) 
						 EXCEPT
						 select column_name 
						 from  information_schema.columns
						 where table_schema = 'bookings'
									and table_name = table_name1
	
	)
	select count(*) counter_col from columns_fake -- return the number of incorrect columns
	into rec;
	RETURN rec;
end;
$$ LANGUAGE plpgsql; 

SELECT * FROM bookings.check_columns('bookings', 'book_ref, book_date');