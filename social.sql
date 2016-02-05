/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);

-- Q1
-- Find the names of all students who are friends with someone named Gabriel. 
select name
from Highschooler 
where ID in (
    select Friend.ID2
    from Friend, Highschooler
    where Highschooler.ID=Friend.ID1 and Highschooler.name='Gabriel');

-- Q2
-- For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. 
select H1.name, H1.grade, H2.name, H2.grade
from Likes, Highschooler H1, Highschooler H2
where H1.ID=Likes.ID1 and H2.ID=Likes.ID2 and H1.grade-H2.grade>=2;

-- Q3
-- For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.
select H1.name, H1.grade, H2.name, H2.grade
from Likes L1, Likes L2, Highschooler H1, Highschooler H2
where L1.ID2=L2.ID1 and L2.ID2=L1.ID1 and L1.ID1=H1.ID and L1.ID2=H2.ID and H1.name<H2.name;

-- Q4
-- Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. 
select name, grade
from Highschooler
where ID not in (
    select ID1 
    from Likes
    union
    select ID2
    from Likes)
order by grade, name;

-- Q5
-- For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 
select H1.name, H1.grade, H2.name, H2.grade
from Likes, Highschooler H1, Highschooler H2
where Likes.ID1=H1.ID and Likes.ID2=H2.ID and Likes.ID2 not in (
    select ID1
    from Likes);

-- Q6
-- Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 
select distinct H1.name, H1.grade
from Friend F1, Highschooler H1, Highschooler H2
where F1.ID1=H1.ID and F1.ID2=H2.ID and H1.grade=(
    select max(H3.grade)
    from Friend F2, Highschooler H3
    where F2.ID2=H3.ID and F2.ID1=F1.ID1) and H1.grade=(
    select min(H3.grade)
    from Friend F2, Highschooler H3
    where F2.ID2=H3.ID and F2.ID1=F1.ID1)
order by H1.grade, H1.name;

-- Q7
-- For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 
select H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from Likes, Highschooler H1, Highschooler H2, Highschooler H3
where Likes.ID2 not in (
    select ID2
    from Friend
    where ID1=Likes.ID1) and H3.ID in (
    select ID2
    from Friend
    where ID1=Likes.ID1) and H3.ID in (
    select ID2
    from Friend
    where ID1=Likes.ID2) and Likes.ID1=H1.ID and Likes.ID2=H2.ID;

-- Q8
-- Find the difference between the number of students in the school and the number of different first names. 
select Num_S-Num_N
from (
    select count(*) as Num_S
    from Highschooler) C1, (
    select count(distinct name) as Num_N
    from Highschooler) C2;

-- Q9
-- Find the name and grade of all students who are liked by more than one other student. 
select Highschooler.name, Highschooler.grade
from Likes, Highschooler
where Likes.ID2 = Highschooler.ID
group by Highschooler.ID
having count(*)>1;