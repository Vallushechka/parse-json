---	check filter
CREATE OR REPLACE FUNCTION bookings.check_filter(filter_name jsonb, schema varchar default 'bookings')
RETURNS integer
AS $$
begin
	if (select array_length((select array(select * FROM jsonb_object_keys(filter_name)
				EXCEPT
				select column_name 
				from  information_schema.columns
				where table_schema = 'bookings'
				and table_name = 'bookings')), 1)) is not null then
	return 0;
	else
	return 1; -- it's okey
	end if;
end;
$$ LANGUAGE plpgsql; 
SELECT * FROM bookings.check_filter('{"book_date": "2017-07-14", "total_amount": "37900.00"}');