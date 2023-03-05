-- companies

drop table if exists data_mart.companies;

create table data_mart.companies as (
	select
		"Company ID" id
		, "Company Name" as name
		-- cast integer timestamp into date for easier data manipulations 
		, (timestamp 'epoch' + "Establishment Date" * interval '1 ms')::date as establishment_date
		, "Number of Employees" as current_employee_count -- could also be employee_count_at_establishment_date
	from
		raw_data.companies
);

alter table data_mart.companies add primary key (id);
