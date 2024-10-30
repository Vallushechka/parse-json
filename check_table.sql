--- table check
CREATE OR REPLACE FUNCTION bookings.check_table(table_name1 varchar, schema varchar default 'bookings')
RETURNS int4
AS $$
DECLARE
	rec int4;
begin
	select count(*) counter_tab from (select unnest(string_to_array(table_name1, ', ')) -- return 0 if the table exists
									  EXCEPT
									  SELECT tablename 
									  FROM pg_tables 
									  WHERE schemaname='bookings')
	into rec;
   RETURN rec;
end;
$$ LANGUAGE plpgsql;

select * FROM bookings.check_table('bookings');
  


