drop table if exists spotify;
create table spotify
	(
		Artist varchar(250),
		Track varchar(250),
		Album varchar(250),
		Album_type varchar(50),
		Danceability float,
		Energy float,
		Loudness float,
		Speechiness float,
		Acousticness float,
		Instrumentalness float,
		Liveness float,
		Valence float,
		Tempo float,
		Duration_min float,
		Title varchar(250),
		Channel varchar(250),
		Views float,
		Likes float,
		Comments bigint,
		Licensed boolean,
		official_video boolean,
		Stream bigint,
		EnergyLiveness float,
		most_playedon varchar(50)
	)	
---------------------------------------------------
-- Basic Analysis
---------------------------------------------------

-- Show all the records
select * from spotify

-- Count the number of records
select count(*) as Numbers from spotify

-- Show all the artist names
select distinct(artist) as Names from spotify order by Names

-- Count the number of artist in this table
select count(distinct(artist)) as Numbers from spotify

-- Show all the album names
select distinct(album) as Names from spotify order by Names

-- Count the number of albums in this table
select count(distinct(album)) as Numbers from spotify

-- Show different album types
select distinct(album_type) as Types from spotify

-- Name of the longest song
select title, duration_min from spotify
where 
duration_min = (select max(duration_min) from spotify)

-- Name of the shortest song
select title, duration_min from spotify
where 
duration_min = (select min(duration_min) from spotify)

-- Name of the different channels
select distinct(Channel) as Types from spotify

-- Count number of different channels
select count(distinct(Channel)) as Numbers from spotify

-- Name of the most liked song
select title, likes from spotify
where likes = (select max(likes) from spotify)

-- Name of the least liked song
select title, likes from spotify
where likes = (select min(likes) from spotify)

--------------------------------------------------
-- Some questions and answers
--------------------------------------------------

-- 1) Retrieve the names of all tracks that have more than 1 billion streams
select track, stream from spotify
where stream > 1000000000 

-- 2) Count the number of tracks that have more than 1 billion streams
select count(track) from spotify
where stream > 1000000000

-- 3) List all albums along with their respective artists
select album, artist from spotify
group by album, artist

-- 4) Count the number of albums where each artists played on
select artist, count(album) from spotify
group by artist

-- 5) Get the total number of comments for tracks which is licensed
select track, comments from spotify where licensed = True

-- 6) Find all tracks that belong to the album type single
select track, album_type from spotify where album_type = 'single'

-- 7) Count the total number of tracks by each artist
select artist, count(track) from spotify
group by artist

-- 8) Calculate the average danceability of tracks in each album
select album, avg(danceability)  as avg_danceability
from spotify
group by album

-- 9) Find the top 10 tracks with the highest energy values
select track, energy from spotify 
order by energy desc
limit 10

-- 10) List all official tracks along with their views and likes
select track, sum(views) as total_views, sum(likes) as total_likes
from spotify
where official_video = True
group by track
order by total_views desc

-- 11) For each album, calculate the total views of all associated tracks
select track, album, sum(views) as total_views
from spotify
group by track, album
order by total_views desc

-- 12) Retrieve the track names that have been streamed on Spotify more than YouTube
select track, stream from spotify
where most_playedon = 'Spotify'
order by stream desc

-- 13) Retrieve the track names that have been streamed on Youtube more than Spotify
select track, stream from spotify
where most_playedon = 'Youtube'
order by stream desc

-- 14) Find the top 3 most viewed tracks for each artist using window functions and CTE
with ranking as
(
select artist, track,
sum(views) as total_views,
dense_rank() over(partition by artist order by sum(views) desc) as rank
from spotify
group by 1,2
order by 1,3 desc
)
select * from ranking 
where rank <= 3

-- 15) Write a query to find tracks where the liveness score is above the average
select track, liveness
from spotify
where liveness > (select avg(liveness) as avg_liveness from spotify)
order by liveness desc

-- 16) Write a query to find official tracks where the like score is above the average
select track, likes
from spotify
where likes > (select avg(likes) as avg_like from spotify)
and official_video = True
order by likes desc

-- 17) Use CTE to calculate the difference between the highest and lowest energy values for tracks in each album
with energy_diff as 
(
select album, max(energy) as highest_energy, min(energy) as lowest_energy
from spotify
group by album
order by album
)
select album, (highest_energy - lowest_energy) as energy_difference
from energy_diff
order by 2 desc

-- 18) Find tracks where the dance-to-loudness ratio is greater than 1.2
with dance_loud_ratio as 
(
select track, (danceability/loudness) as danceability_to_loudness_ratio
from spotify
group by 1, 2
order by 1 desc
)
select track, danceability_to_loudness_ratio
from dance_loud_ratio
where danceability_to_loudness_ratio > 1.2
order by 2 desc

-- Query Optimization

explain analyse 
select artist, track from spotify
where artist like 'Justin%'
order by track
limit 25

--Without index query execution time is 3 ms

explain analyse 
select artist, track from spotify
where artist like 'Justin%'
order by track
limit 25

create index index_artist on spotify(artist)

--With index query execution time is 2 ms