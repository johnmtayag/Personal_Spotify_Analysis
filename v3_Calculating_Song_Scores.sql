-- ########### For each song with a duration, find the average percentage of the song streamed for each song in the dataset
-- Output the song, artist, duration, the number of streams, average streamtime, and average percentage streamed

ALTER VIEW avg_perc_streamed AS 
SELECT c.both_id,
	   c.trackName, 
	   c.artistName, 
       t.duration, 
       COUNT(*) AS num_stream,
       ROUND(AVG(c.msPlayed), 2) AS avg_msPlayed,
       ROUND(AVG(c.msPlayed)/t.duration * 100, 2) AS avg_perc_streamed
FROM combined_data c
INNER JOIN track_data t ON c.both_id = t.both_id AND t.duration > 0 AND c.msPlayed <= t.duration
GROUP BY both_id;

SELECT * FROM avg_perc_streamed;
	

-- ####################### Find the total streamtime and number of streams for each song in the dataset
-- Also find the percentile for each song
ALTER VIEW num_stream_data AS
SELECT both_id, trackName, artistName, SUM(msPlayed) AS total_streamtime_ms, COUNT(*) AS num_stream,
	ROUND(CUME_DIST() OVER (ORDER BY COUNT(*)) * 100, 2) AS num_stream_score
FROM combined_data
GROUP BY both_id
ORDER BY num_stream DESC;

SELECT * FROM num_stream_data;

-- ######################### Score the songs in the dataset according to number of skips
-- # streams / (N_10 * 3) + (N_30 * 2) + (N_90 * 1) + 1
-- N_10: # skips before 10s (10,000ms)
-- N_30: # skips before 30s (30,000ms)
-- N_90: # skips before 90s (90,000ms)
ALTER VIEW skip_score_data AS
WITH skip_rank_data (both_id, track_name, artist_name, msPlayed, duration, num_stream, n_10, n_30, n_90, n_skipped, skip_tracker) AS (
	SELECT c.both_id,
		   c.trackName, 
		   c.artistName,
		   c.msPlayed,
		   t.duration, 
		   COUNT(*) AS num_stream,
		   SUM(CASE WHEN c.msPlayed < 10000 THEN 1 ELSE 0 END),
		   SUM(CASE WHEN c.msPlayed < 30000 THEN 1 ELSE 0 END),
		   SUM(CASE WHEN c.msPlayed < 90000 THEN 1 ELSE 0 END),
           SUM(CASE WHEN c.msPlayed < (t.duration - 10000) THEN 1 ELSE 0 END),
           SUM(CASE
					WHEN c.msPlayed < 10000 THEN 3
                    WHEN c.msPlayed < 30000 THEN 2
                    WHEN c.msPlayed < t.duration - 10000 THEN 1
                    ELSE 0
				END)
	FROM combined_data c
	INNER JOIN track_data t ON c.both_id = t.both_id AND t.duration > 0 AND c.msPlayed <= t.duration
	GROUP BY c.both_id
)
SELECT both_id,
	   track_name, 
	   artist_name, 
	   num_stream,
	   ROUND(n_10/num_stream * 100, 2) AS perc_skip_10,
	   ROUND(n_30/num_stream * 100, 2) AS perc_skip_30,
	   ROUND(n_90/num_stream * 100, 2) AS perc_skip_90,
       ROUND(n_skipped/num_stream * 100, 2) AS perc_skipped,
	   ROUND((num_stream - skip_tracker)/num_stream * 100, 2) AS skip_score,
       ROUND(CUME_DIST() OVER (ORDER BY (num_stream - skip_tracker)/num_stream) * 100, 2) AS skip_cume_dist
FROM skip_rank_data
ORDER BY skip_cume_dist DESC;

SELECT * FROM skip_score_data;


-- ########################### Find the listening score for each song
ALTER VIEW overall_score AS
SELECT a.trackName, a.artistName, a.num_stream, a.avg_perc_streamed, n.num_stream_score, s.skip_cume_dist,
	   ROUND((a.avg_perc_streamed + n.num_stream_score + s.skip_cume_dist)/3, 2) AS score
FROM avg_perc_streamed a
INNER JOIN num_stream_data n ON a.both_id = n.both_id
INNER JOIN skip_score_data s ON a.both_id = s.both_id
ORDER BY score DESC;

SELECT * FROM overall_score;