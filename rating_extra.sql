/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

-- Q1
-- Find the names of all reviewers who rated Gone with the Wind.
select distinct name
from Reviewer join Rating using(rID) join Movie using(mID)
where title='Gone with the Wind';

-- Q2
-- For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 
select name, title, stars
from Reviewer join Rating using(rID) join Movie using(mID)
where name=director;

-- Q3
-- Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 
select name as C
from Reviewer
union
select title as C
from Movie
order by C;

-- Q4
-- Find the titles of all movies not reviewed by Chris Jackson. 
select title
from Movie
where title not in (
    select title
    from Reviewer join Rating using(rID) join Movie using(mID)
    where name='Chris Jackson');

-- Q5
-- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 
select distinct C1.name, C2.name
from (Reviewer join Rating using(rID)) C1, (Reviewer join Rating using(rID)) C2
where C1.mID=C2.mID and C1.rID!=C2.rID and C1.name<=C2.name
order by C1.name, C2.name;

-- Q6
-- For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
select name, title, stars
from Reviewer join Rating using(rID) join Movie using(mID)
where stars=(
    select min(stars)
    from Rating);

-- Q7
-- List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 
select title, avg(stars) as AVG
from Movie join Rating using(mID)
group by title
order by AVG desc, title;

-- Q8
-- Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.) 
select name
from Reviewer join Rating using(rID)
group by rID
having count(*)>=3;

-- Q9
-- Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 
select title, director
from Movie
where director in (select director
    from Movie
    group by director
    having count(*)>1)
order by director, title;

-- Q10
-- Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 
select title, AVG
from (
    select title, avg(stars) AVG
    from Movie join Rating using(mID)
    group by mID)
where AVG=
    (select max(AVG)
    from (
        select avg(stars) AVG
        from Movie join Rating using(mID)
        group by mID));

-- Q11
-- Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 
select title, AVG
from (
    select title, avg(stars) AVG
    from Movie join Rating using(mID)
    group by mID)
where AVG=
    (select min(AVG)
    from (
        select avg(stars) AVG
        from Movie join Rating using(mID)
        group by mID));

-- Q12
-- For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 
select distinct director, title, stars
from (Movie join (
    select director, max(stars) MAX_STAR
    from Movie join Rating using(mID)
    group by director
    having director is not null) using(director)) join Rating using(mID)
where stars=MAX_STAR;

