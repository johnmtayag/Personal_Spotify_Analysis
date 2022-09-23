-- ########### EXTRA ANALYSIS
-- Bin the songs according to number of streams to see the highest scores for each bin
-- Bin 0: 0-5 streams
-- Bin 1: 6-10 streams
-- Bin 2: 11-25 streams
-- Bin 3: 26-50 streams
-- Bin 4: 51-75 streams
-- Bin 5: 76-100 streams
-- Bin 6: More than 100 streams
CREATE VIEW binned_score AS
WITH n_stream_data (track_name, artist_name, num_stream) AS (
	SELECT trackName, artistName, COUNT(*) FROM combined_data
	GROUP BY both_id
)
SELECT CASE 
			WHEN n.num_stream < 6 THEN 0
			WHEN n.num_stream < 11 THEN 1
			WHEN n.num_stream < 26 THEN 2
			WHEN n.num_stream < 51 THEN 3
			WHEN n.num_stream < 76 THEN 4
			WHEN n.num_stream < 101 THEN 5
			ELSE 6
			END AS bins,
		o.trackName, 
        o.artistName, 
        o.num_stream, 
        o.avg_perc_streamed, 
        o.num_stream_score, 
        o.skip_cume_dist,
	    o.score
FROM n_stream_data n
INNER JOIN overall_score o ON o.trackName = n.track_name AND o.artistName = n.artist_name
ORDER BY score DESC;

SELECT * FROM binned_score;