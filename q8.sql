--CS1555 Assignment8 
--Part 1 Q3
--Siming Zheng
--siz11
--4/16/18

--3
--(a)
insert into road values (5, 'century road', 200);
insert into intersection
select f.forest_no, r.road_no
from forest f, road r
where f.name = 'Allegheny National Forest' 
and r.road_no = 5;

--(b)
update sensor
set maintainer = 
case 
when maintainer in (select ssn from worker where name = 'Mike')
then (select ssn from worker where name = 'Jason')
when maintainer in (select ssn from worker where name = 'Jason')
then (select ssn from worker where name = 'Mike')
else maintainer
end;
commit;