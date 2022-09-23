DROP TABLE IF EXISTS combined_data
DROP TABLE IF EXISTS artist_data
DROP TABLE IF EXISTS track_data

CREATE TABLE combined_data (
	stream_id INT PRIMARY KEY,
	endTime DATETIME,
	artistName VARCHAR(50),
	trackName VARCHAR(75),
	msPlayed INT,
	both VARCHAR(125),
	genres VARCHAR(30)
);

CREATE TABLE artist_data (
	artist_id VARCHAR(25) PRIMARY KEY,
	artist VARCHAR(50),
	popularity INT,
	followers INT,
	num_genres INT,
	genres VARCHAR(30)
);

CREATE TABLE track_data (
	track_id VARCHAR(25),
	trackName VARCHAR(75),
	artist VARCHAR(50),
	both VARCHAR(125) PRIMARY KEY,
	duration INT,
	artist_id VARCHAR(25),
	explicit_val BIT,
	genres VARCHAR(30)
);

BULK INSERT combined_data
FROM 'C:\Users\johnt\Desktop\SQL_Learning\spotify_data\combined_df.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FIELDQUOTE = '"',
	ROWTERMINATOR = '\n'
);

BULK INSERT artist_data
FROM 'C:\Users\johnt\Desktop\SQL_Learning\spotify_data\artist_info.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FIELDQUOTE = '"',
	ROWTERMINATOR = '\n'
);

BULK INSERT track_data
FROM 'C:\Users\johnt\Desktop\SQL_Learning\spotify_data\track_info.csv'
WITH (
	FORMAT = 'CSV',
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	FIELDQUOTE = '"',
	ROWTERMINATOR = '\n'
);
	
