-- create databse
create database learning;

-- remove database
drop database learning;

-- Use database
use learning;
-- create table skills
create table skills(
	id int primary key auto_increment,
    title varchar(100)
);
-- add column to exisitng table
alter table skills add proficiency enum ('professional', 'experienced','beginner');

-- drop existing column
alter table skills drop proficiency;

-- alter column_type
alter table skills modify column proficiency enum ('professional', 'experienced','beginner','forgotten');

-- drop the index of table
alter table skills drop index id;

-- Error Code: 1091. Can't DROP 'id'; check that column/key exists --

-- rename table
alter table skills rename to tech_skills;
-- drop table


drop table tech_skills;
-- descibe table definition
describe table skills;

create table domain(
 code int primary key auto_increment,
 domain varchar(100)
 );
 
 -- add columne for forign key in skills
alter table skills add column domain_code int;
 
 -- change the datatype for coumn code
alter table domain modify column code varchar(10);

-- modify foreign key type to match with domain table
alter table skills modify column domain_code varchar(10);

-- add constraint
alter table skills add foreign key(domain_code) references domain(code)  on delete cascade;

 -- to see all the system added constraint
select *
from information_schema.Table_Constraints where table_name = 'skills';

-- to drop a foreign key
alter table skills drop constraint skills_ibfk_1;

-- value insertion
insert into domain
(code, domain) values
('PL','Programming Language'),
('DB','Data base');

insert into domain
(code, domain) values
('SCRIPT','Scripting Language'),
('CI/CD','Continuous Integration and Continuous Delivery'),
('VC','Version Control Managment');

-- delete all rows from table domain
delete from domain ;
-- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.

-- solution
SET SQL_SAFE_UPDATES = 0;

insert into skills
 (title, proficiency,domain_code) values
 ('JAVA','professional','PL'),
 ('PYTHON','experienced','PL'),
 ('MY SQL','experienced','PL');
 
  -- update value of some row
 update skills set domain_code='DB' where title= 'MY SQL';
 
 insert into skills
 (title, proficiency,domain_code) values
 ('JAVASCRIPT','experienced','SCRIPT'),
 ('MAVEN','experienced','CI/CD'),
 ('Oracle SQL','experienced','PL'),
 ('Git','professional','VC');
 -- delete all
 delete from skills;
 -- select querry
 
  update skills
  set domain_code= 'DB' where title="Oracle SQL";
 
create table total_experience(
	skill_id int,
    learning_from year,
    foreign key(skill_id) references skills(id) on delete cascade
);

insert into total_experience
	(skill_id, learning_from) values
    (7, 2008),
    (8, 2018),
    (9, 2015),
    (10,2019),
    (11,2016),
    (12,2021),
    (13,2016);
 
 select * from skills;

-- select all skill in which your are experienced

select * from skills where proficiency='experienced';

-- select only one column
select title from skills where proficiency='experienced';

-- select types of proficiency
-- we use distinct if one or more column would result in same results, thento only get unique results
select distinct proficiency from skills;

-- commit change and mark new state
commit;
savepoint stage1;

-- rollback to last change
rollback;

-- rollback to secific state
rollback to stage1;



-- joining multiple table
-- select all progrmaing language with proficiency as professional
select * from skills s, domain d
where s.domain_code= d.code and d.code='PL' and s.proficiency='professional';

-- selecting same column adjacent to each other
select s1.title as Language1, s2.title as Language2 from skills s1
join skills s2 on s1.id < s2.id
where s1.proficiency='professional' or s2.proficiency='professional';

-- combining results from two qurries
select title from skills s, domain d
where s.domain_code= d.code and d.code='PL' and s.proficiency='professional'
UNION
select title from skills s, domain d
where s.domain_code= d.code and d.code='PL' and s.proficiency='experienced';

-- This won't work
select * from skills
UNION 
select * from domain;

-- Error Code: 1222. The used SELECT statements have a different number of columns

-- this will work, heading of first querry is considered.
select id, title from skills
UNION 
select * from domain;


-- sub-query
-- use in if more than one result is returned
select * from skills
where title in (select title from skills where domain_code='PL');

-- pattern matching
select title from skills
where title like "%Java%";

-- find skill with max experience
select  MAX(2023 - learning_from) as max from total_experience;
-- This won't work
select skills.title, MAX(2023 - learning_from) from total_experience
join skills on  total_experience.skill_id = skills.id;
 -- Error Code: 1140. In aggregated query without GROUP BY, expression #1 of SELECT list contains nonaggregated column 'learning.skills.title'; this is incompatible with sql_mode=only_full_group_by

-- we need to add group by to make it work
select  skills.title, MAX(2023 - learning_from) as max from total_experience
join skills on  total_experience.skill_id = skills.id
group by title
order by max desc
limit 1;

-- thiw will also give same result
select skills.title,(2023 - learning_from) as total_year from total_experience
join skills on total_experience.skill_id = skills.id
where (2023 - learning_from) = ( select MAX(2023 - learning_from) as max from total_experience );

-- select count of skills with more than 3 year experience
select count((2023 - learning_from)> 3) as 'skills with more then 3 years of experience'  from total_experience
join skills on total_experience.skill_id = skills.id;


-- select the domain for which you have atleast 2 skills
select domain_code, count(title) as count from skills
group by domain_code
having count >1;

-- views -->

-- create a view for all skills which you ar experienced for more than 3 years
create view experienced as 
select title , ((2023 - learning_from)> 3) as 'total experience > 3' from skills
join total_experience on total_experience.skill_id = skills.id
where proficiency='experienced' ;
select * from experienced;
-- wrong output

-- to alter the view
alter view experienced as 
select title ,learning_from, (2023 - learning_from) as total_experience from skills
join total_experience on total_experience.skill_id = skills.id
where proficiency='experienced' and (2023 - learning_from)> 3;

select * from experienced;

-- we can update the view if we like but this will change the real database
-- As The data "in" a view has no existence independent from the tables that make up the view
-- let's say we want to change the learning_from for MY_SQL to 2014

update experienced set learning_from=2014 where title='MY SQL';
select * from experienced;

-- if we see the real table its also updated
select title,learning_from from skills 
join total_experience on total_experience.skill_id = skills.id
where title='MY SQL';

-- Error Code: 1348. Column 'total_experience' is not updatable
-- as no column exisit in table with name total_experience
insert into experienced
(title,learning_from,total_experience)
values ('SCALA',2022,5);

-- if our view was 
alter view experienced as 
select title ,learning_from from skills
join total_experience on total_experience.skill_id = skills.id
where proficiency='experienced' and (2023 - learning_from)> 3;

select * from experienced;

-- if we now try to insert
-- Error Code: 1393. Can not modify more than one base table through a join view 'learning.experienced'
-- because at times view can only inseet data in one table
insert into experienced
(title,learning_from)
values ('SCALA',2022);

-- now we alter the view to contain data from only ne table
alter view experienced as 
select title  from skills
join total_experience on total_experience.skill_id = skills.id
where proficiency='experienced' and (2023 - learning_from)> 3;

-- and try insert operation, is successfull
insert into experienced
(title)
values ('SCALA');

-- but we don't see the data here as it doens't match where clause proficiency and greater than 3
select * from experienced;

-- but our data has been inserted succesfully in skills table with null values for missing column
-- this will work only missing column allow null values
select * from skills;


-- if we want to insert only if it matches the constrain then use with check option
alter view experienced as 
select title  from skills
join total_experience on total_experience.skill_id = skills.id
where proficiency='experienced' and (2023 - learning_from)> 3
with check option;

-- now if we try to insert
-- we get error Error Code: 1369. CHECK OPTION failed 'learning.experienced'
insert into experienced
(title)
values ('GOLANG');

commit;
savepoint views;


