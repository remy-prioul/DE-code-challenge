-- job_postings

drop table if exists data_mart.job_postings;

-- this table would make sense to help answer question 6 but not with the current data
-- built as an example (would need additional work)
create table data_mart.job_postings as (
    select
		uuid_generate_v4() as id
        , id as job_id
        -- this is good enough for adhoc analysis but not an elegant solution
        , case
            when state in ('cancelled', 'canceled') then 'canceled'
            when state in ('osted', 'posted') then 'posted'
            when state = 'expired' then 'expired'
            else 'unknown'
        end as state
        , price
        -- updates to a job post are missing in the dataset
        -- so using posted_at as a default for the sake of the exercise 
        , posted_at as updated_at
    from
        raw_data.jobs
);

alter table data_mart.job_postings add primary key (id);
alter table data_mart.job_postings add constraint fk_job_postings_jobs
    foreign key (job_id) references data_mart.jobs (id);
