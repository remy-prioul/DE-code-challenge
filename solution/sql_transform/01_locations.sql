-- locations

drop table if exists data_mart_locations;

create table data_mart.locations as (
	select
		uuid_generate_v4() as id
		, location as name
		, zip_code as zip_code
	from
		raw_data.locations
);

alter table data_mart.locations add primary key (id);
