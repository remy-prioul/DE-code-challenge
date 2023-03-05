# GOhiring Data Engineer Code Challenge

## Introduction

To solve the proposed exercise, I'd like to propose the following solution:
1. Initial data exploration will be done in a Python notebook. This serves multiple purposes:
   * Get a first understanding of the data model, entities and relationship between them.
   * Identify some (but not necessarily all at this point) data quality issues, missing fields and other complications.
   * Get comfortable with the data types in all the fields.

2. Based on the initial data exploration, creation of a data model that will capture all relevant information from the data:
    * Illustrated by an Entity Relationship Diagram
    * The relevant `CREATE TABLE` SQL statements to implement this in a database

3. Data loading into a database (postgresql in that case) in a 2-step process:
   1. First, a 1-to-1 replication of the original data in a `raw data` layer. This would be an equivalent of what is commonly called a data lake
   2. Then, a transformation of our raw data (cleaning up, deduplication, enrichment) to fit into our previously defined data model.
   * If during the transformation, issues are arising, this might indicate the need to re-iterate on step 2.

4. **Questions** section answers

## 1. Data Exploration

Please see the attached [data_exploration.ipynb](./data_exploration.ipynb).

**Key takeaways for the rest of exercise:**
* Based on the rest of the questions in the exercise, it appears necessary to have a connection between `jobs` and `companies` but there doesn't to be an immediate connection between the 2.
* I will make the following assumption in order to be able to move forward with the rest of the work: only one company can have jobs published at a single time. That way based on the history in `companies`, I'll be able to derive the time ranges in which companies had job postings. Combining this with the `posted_at` from `jobs`, I'll be able to map jobs to companies.

## 2. Data Modelling & 3. Data Loading

Please see the attached [ERD](./ERD.png) as well as the SQL files in the [SQL transform folder](./sql_transform/).

I've only focused in terms of constraints on PK and FK as it could be dangerous to add any additional constraints (non null-ness and others) without knowledge of the process generating the initial data.

To bring the data into the database, I've leverage Pandas dataframes and the `to_df()` method. In production environment, it could be possible to use the built-in `COPY` command that exists in most SQL flavors to directly import data into the DB.

## 4. Questions

1. What location has the most jobs that are either posted or expired?
```sql
select
	l.name
	, count(distinct j.id)
from
	data_mart.job_postings as jp
	join data_mart.jobs as j on (j.id = jp.job_id)
	join data_mart.locations as l on (l.id = j.location_id)
where
	jp.state in ('posted', 'expired')
group by
	l.name
order by
	count(distinct j.id) desc
;
```

Result: Tarth with 15 jobs

2. What month had the most cancelled jobs?

```sql
select
	to_char(updated_at, 'mon') as month
	, count(distinct job_id)
from
	data_mart.job_postings
where
	state = 'canceled'
group by
	month
order by
	count(distinct job_id) desc
;
```

Result: June with 7 jobs

3. Which company has the highest ratio of posted jobs to employee count?

```sql
select
	c.id
	, c.name
	, c.establishment_date
	, count(distinct j.id) as posted_jobs
	, count(distinct j.id)::decimal / c.current_employee_count as ratio
from
	data_mart.companies as c
	join data_mart.jobs as j on (j.company_id = c.id)
	join data_mart.job_postings as jp on (jp.job_id = j.id)
where
	jp.state = 'posted'
group by
	c.id
	, c.name
	, c.establishment_date
	, c.current_employee_count
order by
	ratio desc
;
```

Result: High Hopes Inc. with 9.6%

4. Develop the SQL to define a dimensional model schema for this data. Document (or be ready to discuss) any design decisions that you make.

Result: Done above in section 2 and 3

5. Using your dimensional model, write a SQL query that returns a list of jobs for each company, ordered and enumerated within each group by the `posted_at` date.

```sql
select
	c.name || ' (' || c.establishment_date || ')' as company
	, string_agg(j.posted_at || ' ' || j.id, '
' order by j.posted_at)
from
	data_mart.companies as c
	join data_mart.jobs as j on (j.company_id = c.id)
group by
	c.name
	, c.establishment_date
;
```

6. Discuss how you would obtain and model information (within your schema) about the duration of jobs (from `posted` to `expired` states).

This could be achieved using the `data_mart.job_postings` tables by looking at the delta between the `updated_at` field for a given `job_id`. Something along those lines:

```sql
with posted as (
	select
		job_id
		, min(updated_at) as posted_at
	from
		data_mart.job_postings
	where
		state = 'posted'
	group by
		job_id
)
, expired as (
	select
		job_id
		, min(updated_at) as expired_at
	from
		data_mart.job_postings
	where
		state = 'expired'
	group by
		job_id
)
select
	p.job_id
	, DATE_PART('day', e.expired_at - p.posted_at)
from
	posted as p
	join expired as e on (e.job_id = p.job_id)
;
```


### Setup a demo postgresql database for the exercise

Linux Ubuntu procedure:

1. Install relevant packages:
    
    `sudo apt install postgresql postgresql-contrib`

2. Verify that the installation was successful:
    
    `service postgresql status`

3. Start interactive session:
    
    `sudo -u postgres psql`

4. Initial checks & password initialization
   * `\conninfo`
   * `\password postgres` -> `lkiQbrJJZHond53syDmV` (`pwgen -s 20`)