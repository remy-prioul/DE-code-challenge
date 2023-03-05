-- jobs

drop table if exists data_mart.jobs;

create table data_mart.jobs as (
    with company_date_ranges as (
        select
            id
            -- the 2 dates below give the range during which a company was active as per my assumption
            , establishment_date
            , coalesce(
                lead(establishment_date) over (order by establishment_date)
                , current_date
            ) as next_establishment_date
        from
            data_mart.companies
    )
    , data_enrichment as (
        select 
            j.id
            , j.posted_at
            , l.id as location_id
            , cdr.id as company_id
            -- row_number to deduplicate
            , row_number() over (partition by j.id order by posted_at desc, _inserted_at desc) as rn
        from
            raw_data.jobs as j
            left outer join data_mart.locations as l on (l.zip_code = j.zip)
            left outer join company_date_ranges as cdr on (
                cdr.establishment_date <= j.posted_at
                and cdr.next_establishment_date > j.posted_at
            )
    )
    select
        id
        , posted_at
        , location_id
        , company_id
    from
        data_enrichment
    where
        rn = 1
);

alter table data_mart.jobs add primary key (id);
alter table data_mart.jobs add constraint fk_jobs_companies
    foreign key (company_id) references data_mart.companies (id);
alter table data_mart.jobs add constraint fk_jobs_locations
    foreign key (location_id) references data_mart.locations (id);
