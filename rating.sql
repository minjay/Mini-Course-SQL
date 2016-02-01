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
-- Find the titles of all movies directed by Steven Spielberg. 
select title
from movie
where director="Steven Spielberg";

-- Q2
-- Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 
select distinct year
from movie, rating
where movie.mID=rating.mID and (stars=4 or stars=5)
order by year asc;

-- Q3
-- Find the titles of all movies that have no ratings. 
select title
from movie
where movie.mID not in (
	select rating.mID from rating);

-- Q4
-- Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 
select name
from Reviewer
where rID in (
	select rID from Rating where ratingDate is null);

-- Q5
-- Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
select name, title, stars, ratingDate
from Movie, Reviewer, Rating
where Movie.mID=Rating.mID and Reviewer.rID=Rating.rID
order by name, title, stars;

-- Q6
-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 
select name, title
from (
	select name, title, Rating.mID, Rating.rID
	from Movie, Reviewer, Rating, (
		select R1.rID, R1.mID 
		from Rating R1 join Rating R2 on
		R1.rID=R2.rID and R1.mID=R2.mID and R1.stars<R2.stars and R1.ratingDate<R2.ratingDate) C
	where Movie.mID=Rating.mID and Reviewer.rID=Rating.rID and Rating.mID=C.mID and Rating.rID=c.rID)
group by name, title
having count(*)=2;

-- Q7
-- For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 
select title, max(stars)
from Movie join Rating using(mID)
group by mID
having count(*)>=1
order by title;

-- Q8
-- For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
select title, max(stars)-min(stars) as spread
from Movie join Rating using(mID)
group by mID
order by spread desc, title;

-- Q9
-- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 
select avg(A.AVG)-avg(B.AVG)
from (
	select mID, avg(stars) as AVG
	from Rating
	where mID in (select mID from Movie where year<1980)
	group by mID) A, 
	 (
	select mID, avg(stars) as AVG
	from Rating
	where mID in (select mID from Movie where year>1980)
	group by mID) B;
