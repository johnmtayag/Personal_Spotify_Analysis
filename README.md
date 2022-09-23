# Spotify Analysis

I have used Spotify since 2016/2017, and for most of those years, I gave no second thought to my listening history. Only when the first Spotify Unwrapped was released did I realize the scale of the data that Spotify was tracking about my listening history. However, each year, Spotify Unwrapped surprises me less and less - by the end of the year, I typically have a very good idea of what my top genres/tracks/artists are. When I discovered that I could request my listening history, I decided to challenge myself to write code to find my favorite genres/tracks/artists in the year so far.

This was my first data analysis project - it was done completely within Python via Jupyter Notebooks. It was also a way for me to play with various tools offered in Python, so this initial iteration is admittedly a bit disorganized. As time passed and I developed my skills in related areas, I would periodically return to this project to improve various aspects, and so this project is presented as successive, often stand-alone iterations.

# v0: Python Analysis Only

The dataset Spotify returns when the user's last year's listening history is requested is very limited, consisting of only 4 columns packed in a JSON format with each row consisting of an individual stream:

>**endTime**: The timestamp marking the end of the stream<br>
>**artistName**: The artist listed on the track<br>
>**trackName**: The title of the track<br>
>**msPlayed**: The streamtime of the track (in ms)

Immediately, this meant there were restrictions on what I could do with this data. For this initial iteration, I wanted to work solely with the data received from Spotify, so I came up with a few work-arounds.:

* Without any genre markers, I could not find my most-listened-to genres of the year
    * Unfortunately, I had to remove genre analysis from the scope of this project
* Without song lengths, I could not determine which of these streams were complete
    * Since the stream lengths were recorded in ms, I theorized that for any track in the dataset, any repeated msPlayed values were most likely the actual song length. I then created a system that would calculated the predicted song length for every track in the dataset
    * This is further elaborated on within the Jupyter Notebook file.
* Songs with the same title were counted as one since there was no unique ID supplied for each track
    * I combined the artist and track names into a separate column to act as IDs

I created several visualizations to understand the trends of the data, including bar charts representing the most-streamed songs and their frequencies. Eventually, using number of streams and total time streamed, I was able to show my top tracks of the year so far.

To make the task more interesting. I decided to tackle one issue that I found with Spotify Unwrapped - its focus solely on the upper percentile. I suspect that to simplify the analysis, Spotify first filters out the most-streamed tracks from each user's listening history (this is likely the Unwrapped playlist that is released along with the application). This is fine for an overview, but it means that the resulting analysis is biased toward songs discovered earlier in the year which had more chances to be streamed.

I successfully created a system to divide the tracks into bins according to number of streams and rank them within their bins according to various metrics:

>**bin 0**: Songs with 1-5 streams<br>
>**bin 1**: Songs with 6-10 streams<br>
>**bin 2**: Songs with 11-25 streams<br>
>**bin 3**: Songs with 26-50 streams<br>
>**bin 4**: Songs with 51-75 streams<br>
>**bin 5**: Songs with 76-100 streams<br>
>**bin 6**: Songs with >100 streams

>**Number of Streams**
>* The number of times a song was streamed relative to other songs in the bin
>**Average Streamtime**
>* The average percentage of a song that was streamed 
>**Number of Skips**
>* Each song was penalized for the number of skips at various stages of the song

The implementation of these metrics was a bit messy in this iteration and was simplified in my later SQL iteration, but it resulted in a successful algorithm which ranked my listening history at various numbers of streams. 

# V1.0: Connecting to Spotify API endpoints

Earlier, I had requested a year's worth of listening data from Spoitify, but Spotify also has an option to request your entire listening history which includes more details about each individual stream (including track IDs). Spotify also has the option to request more information about tracks/artists/etc. via its API endpoints. Together, these prompted me to return to this project to fill in some gaps from the previous analysis.

With my entire listening data, I'd be able to see trends in my musical tastes as it developed over the years, and because the data included track IDs, I could request more track information. In particular, I now had a way to obtain track lengths and genres.

Using SpotiPy's audio_features() function, I created a data frame which would contain individual track details which included track lengths. 

It was a bit harder to determine track genres as the genres are instead tied to the artist. Therefore, all songs from the same artist would have the same genre, no matter what the song's actual genre is. Also, not all artists on Spotify had an associated genre stored. As a result, any analysis regarding song genres would not be perfectly accurate. Despite these limitations, I continued with the analysis because I was still curious as to the result.

I used SpotiPy's search() function to request and extract all available artist genres from my dataset.

Finally, I did a bit of data cleaning to remove any duplicates and missing values. I also went ahead and removed sleep ASMR tracks as I was not interested in those.

In the end, I had a set of related datasets that each contained data on my listening history:

# V1.1: Power BI Visualizations

While Python offers several good data visualization libraries, I wanted to try visualizing the data using a tool created more specifically for the task. I chose Power BI as I was already familiar with the Microsoft Office environment and for its versatility. A PDF of the finished dashboard is included in the repository, but the dashboard itself is fully interactive with the ability to filter the visuals by various categories including date, artist, and track.

I used the datasets that I created while experimenting with SpotiPy in the v1.0 iteration which allowed me to focus particularly on yearly genre breakdowns.

The first page offers an overview which shows the top genres over some period of time by number of streams, as well as a breakdown of the top songs within each genre. More information about each artist and track are included in tables on the same page.

The second page has a ribbon chart which shows the most-streamed genres of each year

# V2.0: Customized Spotify API

The previous iterations focused on my entire listening history, but now I wanted to take what I learned and use the API to extract song lengths and genres for yearly Spotify listening history analysis. This would allow for more robust datasets for future analyses.

I also experimented with customizing my own API to interact with Spotify's endpoints. This enabled me to develop my Python skills further and also allowed me to customize the API outputs more directly than I was able to using SpotiPy. The most important consequence was that I was able to catch more edge cases where searches failed for various reasons.

The resulting datasets from this iteration allowed me to create a variation of the Power BI visualization that I had created earlier which would break down the past year's listening history (instead of the entire listening history). This dashboard is still a prototype and will be enhanced in the future.

# V3.0: Analysis via SQL

Previously, I did all of my data processing in Python which was my area of expertise. However, to round out my skills, I taught myself SQL, so to test my skills, I decided to build a database and analyze my data solely within the SQL environment.

For this, I used the resulting datasets from the v2.0 iteration which included song lengths and genres pulled from Spotify via its API endpoints:

>**artist_info**: Contains information on all artists in the dataset<br>
>**track_info**: Contains information on all tracks in the dataset<br>
>**combined_df**: Contains information on all individual streams of the past year

My original scoring system in the v1.0 iteration was a bit messy as I had to work with limited data, but now that I had actual song lengths, I could simplify the analysis.

For each song, I calculated the average percent streamed, the percentile rank according to number of streams, and the percentile rank according to the number of skips at specific time intervals. I then calculated a score for each song which represented how much I enjoyed that song. In theory, the highest scoring song would be streamed 100% every stream, would be streamed the most out of all songs, and would have no skips.

I then created an additional view which divided the data into bins and outputted the top 10 songs according to differing numbers of streams (the same as previously).

The resulting datasets showing the top tracks and their scores are attached:

>**v3_SQL_Analysis_overall_scores**: The view stored as "overall_score"<br>
>**v3_SQL_Analysis_overall_scores**: The view stored as "top_10_per_bin"