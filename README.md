# Analyzing My Spotify Listening History

I have been using Spotify since 2016/2017, but until I discovered Spotify Wrapped, I had not realized the scale of the data that Spotify was tracking regarding my listening history. However, each year, Spotify Wrapped surprises me less and less as by the end of the year, I typically have a very good idea of what my top genres/tracks/artists are. Thus, when I discovered that I could request my personal listening history, I decided to challenge myself to write some code to find my favorite genres/tracks/artists in the year so far.

<p align="center">
    <img src="images\Spotify_minListening.png" height="500"><br>
    <em>Example screenshot from Spotify Wrapped</em>
</p>
<br>

The first iteration was my first data analysis project - it was done completely within Python via Jupyter Notebooks. It was also a way for me to play with various tools offered in Python and hone my skills with different libraries, so this initial iteration is admittedly a bit disorganized. As time passed, I developed my skills in related areas, and so I would periodically return to this project to improve various aspects. Thus, this project is presented as successive, often stand-alone iterations that build on the work I had done previously.

# v0: Analyzing in Python Only

The dataset Spotify returns when the user's last year's listening history is requested is very limited, consisting of only 4 columns packed in a JSON format with each row consisting of an individual stream:

>**endTime**: The timestamp marking the end of the stream<br>
>**artistName**: The artist listed on the track<br>
>**trackName**: The title of the track<br>
>**msPlayed**: The streamtime of the track (in ms)

<p align="center">
    <img src="images\Spotify_year_data_screenshot.PNG" height="300"><br>
    <em>Example data from the JSON file(s)</em>
</p>
<br>
The overall lack of data limited the scope of this project, but I came up with a few work-arounds:

* Without any genre data, I could not find my most-listened-to genres of the year
    * Unfortunately, I had to remove genre analysis from the scope of this project
* Without song lengths, I could not determine which of these streams were complete
    * Since the stream lengths were recorded in ms, I theorized that for any track in the dataset, any repeated msPlayed values were most likely the actual song length. I then created a system that would calculated the predicted song length for every track in the dataset
    * This is further elaborated on within the Jupyter Notebook file.
* Songs with the same title were counted as one since there was no unique ID supplied for each track
    * I combined the artist and track names into a separate column to act as IDs to differentiate these instances

<p align="center">
    <img src="images\Unwrapped_results.PNG" height="500"><br>
    <img src="images\Spotify_year_data_tracksByNumStream.png" height="300">
</p>
<p align="center">
    <em><b>Top:</b> The top 5 songs according to Spotify Unwrapped<br>
    <b>Bottom:</b> The top 10 songs from my listening history by number of streams descending
    </em>
</p>
<br>

By simply counting the number of streams for each song, the top 2-6 songs matched up exactly with the top song results from my Spotify Unwrapped - though why Son of Beast was excluded is unknown to me as of now:

To make the task more interesting. I decided to tackle one issue that I found with Spotify Unwrapped - its focus solely on the upper percentile tracks. I suspect that to simplify the analysis, Spotify first filters out the most-streamed tracks from each user's listening history (this is likely the Unwrapped playlist that is released along with the application). This is fine for an overview, but the results are biased toward songs discovered earlier in the year which had more chances to be streamed. For example, if I discovered a song in December which ended up being one of my favorite songs of the year, unless I streamed it constantly, it most likely would not show up in my Unwrapped analysis (or at the very least, it would most likely not rank highly) as other songs will have been streamed throughout the year already.

I divided the tracks into bins according to number of streams and ranked them within their bins according to various metrics. This would allow me to rank songs with different numbers of streams:

As can be seen in the chart, the vast majority of tracks were streamed less than 10 times - were I to only focus on the most-streamed songs, much of the dataset would be cut. That would be good for efficiency, but I wanted to know more about these tracks.

>**Bin 0**: Songs with 1-5 streams<br>
>**Bin 1**: Songs with 6-10 streams<br>
>**Bin 2**: Songs with 11-25 streams<br>
>**Bin 3**: Songs with 26-50 streams<br>
>**Bin 4**: Songs with 51-75 streams<br>
>**Bin 5**: Songs with 76-100 streams<br>
>**Bin 6**: Songs with >100 streams

<p align="center">
    <img src="images\Spotify_year_data_piechart_binnedsongs.PNG" height="300"><br>
</p>

**Metrics**:<br>
>**Number of Streams**: The number of times a song was streamed (relative to other songs in the bin)<br>
>* Defined here as the percentile rank within the bin of each song's number of streams
>   * Note: Taking the percentile rank within the bin instead of the percentile rank overall means songs from bins with less streams may appear higher in the rankings if they score well in other categories. This affected the overall scores greatly.

>**Average Streamtime**: The average percentage of a song that was streamed across all streams<br>
>* Defined here as the overall average percentage of song streamed for each song's streams according to the calculated song duration

>**Number of Skips**: Each song was penalized for the number of "skips" at certain points of the song 
>* i.e., for every stream, a point is deducted for:
>   * A skip within 10 seconds (<10,000 ms, labeled as N_10s)
>   * A skip within 30 seconds (<30,000 ms, labeled as N_30s)
>   * A skip within 90 seconds (<90,000 ms, labeled as N_90s)
>   * A skip before 10 seconds from the ending of the song (labeled as N_Unfinished)
>* Other variables:
>   * N_Skips: Total number of N_Unfinished instances for each song
>   * N_CompletedStreams: Number of streams - Number of Skips
<p align="center">
    <img src="images\v0_skipEquation.PNG" height="75"><br>
    <em>The equation for the value of this metric</em>
</p>


The implementation of these metrics was a bit messy in this iteration and was simplified in my later SQL iteration, but it resulted in a successful algorithm which ranked my listening history at various numbers of streams. The output was mainly text-based, however, so later iterations of this project would focus on creating visuals to understand the data.
<br><br>
<p align="center">
    <img src="images\Spotify_year_data_exampleResults.PNG" height="500"><br>
    <em>A small excerpt of the output from this analysis</em>
</p>

# V1.0: Connecting to Spotify API Endpoints For More Information

Earlier, I had requested a year's worth of listening data from Spotify, but Spotify also has an option to request your entire listening history which includes more details about each individual stream (including track IDs). Spotify also has the option to request more information about tracks/artists/etc. via its API endpoints. Together, these prompted me to return to this project to fill in some gaps from the previous analysis.

With my entire listening data, I'd be able to see trends in my musical tastes as it developed over the years, and because the data included track IDs, I could request more track information. In particular, I now had a way to obtain track lengths and genres.

Using SpotiPy's audio_features() function, I created a data frame which would contain individual track details which included track lengths. 

It was a bit harder to determine track genres as the genres are instead tied to the artist. Therefore, all songs from the same artist would have the same genre, no matter what the song's actual genre is. Also, not all artists on Spotify had an associated genre stored. As a result, any analysis regarding song genres would not be perfectly accurate. Despite these limitations, I continued with the analysis because I was still curious as to the result.

I used SpotiPy's search() function to request and extract all available artist genres from my dataset.

Finally, I did a bit of data cleaning to remove any duplicates and missing values. I also went ahead and removed sleep ASMR tracks as I was not interested in those.

In the end, I had a set of related datasets that each contained data on my listening history:
<br><br>
<p align="center">
    <img src="images\v1_artistdf.PNG" height="300"><br>
    <em>Data frame containing artist information with the new genre information boxed</em>
</p>

<p align="center">
    <img src="images\v1_trackdf.png" height="250"><br>
    <em>Data frame containing track information with the new duration information boxed</em>
</p>

# V1.1: Visualizing the Data with Power BI

While Python offers several good data visualization libraries, I wanted to try visualizing the data using a tool created more specifically for the task. I chose Power BI as I was already familiar with the Microsoft Office environment and for its versatility. A PDF of the finished dashboard is included in the repository, but the dashboard itself is fully interactive with the ability to filter the visuals by various categories including date, artist, and track.

I used the datasets that I created while experimenting with SpotiPy in the v1.0 iteration which allowed me to focus particularly on yearly genre breakdowns.

The first page offers an overview which shows the top genres over some period of time by number of streams, as well as a breakdown of the top songs within each genre. More information about each artist and track are included in tables on the same page:

<p align="center">
    <img src="images\v1_1_page1.PNG" width="1000"><br>
</p>

The second page has a ribbon chart which shows the most-streamed genres of each year:

<p align="center">
    <img src="images\v1_1_page2.PNG" width="1000"><br>
</p>

# V2.0: Customized Spotify API for Customizing Data Requests

The previous iterations focused on my entire listening history, but now I wanted to take what I learned and use the API to extract song lengths and genres for yearly Spotify listening history analysis. This would allow for more robust datasets for future analyses.

I also experimented with customizing my own API to interact with Spotify's endpoints. This enabled me to develop my Python skills further and also allowed me to customize the API outputs more directly than I was able to using SpotiPy. The most important consequence was that I was able to catch more edge cases where searches failed for various reasons.

The resulting datasets from this iteration allowed me to create a variation of the Power BI visualization that I had created earlier which would break down the past year's listening history (instead of the entire listening history). This dashboard is still a prototype and will be enhanced in the future.

<p align="center">
    <img src="images\v2_yearly_version.PNG" width="1000"><br>
</p>


# V3.0: Analyzing Using SQL

Previously, I did all of my data processing in Python which was my area of expertise. However, to round out my skills, I taught myself SQL, so to test my skills, I decided to build a database and analyze my data solely within the SQL environment.

I set up a local database using Microsoft SQL Server and uploaded the datasets derived from the v2.0 iteration (which included song lengths and genres pulled from Spotify via its API endpoints):

>**artist_info**: Contains information on all artists in the dataset<br>
>**track_info**: Contains information on all tracks in the dataset<br>
>**combined_df**: Contains information on all individual streams of the past year

My original scoring system in the v1.0 iteration was a bit messy as I had to work with limited data, but now that I had actual song lengths, I could simplify the analysis. I decided to keep the 3 metrics from earlier, but I defined them differently this time:

**Metrics**:<br>
>**Number of Streams**: The number of times a song was streamed (relative to other songs in the bin)<br>
>* Defined here as the percentile rank (within the bin) of each song's number of streams
>   * Note: The original iteration used the percentile rank according to each bin in the calculation for the overall score. This analysis takes the percentile rank across the entire dataset.

>**Average Streamtime**: The average percentage of a song that was streamed across all streams<br>
>* Defined here as the overall average percentage of song streamed for each song's streams

>**Number of Skips**: Each song was penalized for the number of "skips" at certain points of the song 
>* i.e., for every stream, a point is deducted for:
>   * A skip within 10 seconds (<10,000 ms)
>   * A skip within 30 seconds (<30,000 ms)
>   * A skip within 90 seconds (<90,000 ms)
>   * A skip before 10 seconds from the ending of the song
>* So if a specific stream is only 2000 ms, then, assuming the duration of the song exceeds 12,000 ms, then a total penalty of 4 points will be added to the song's score

I then averaged all 3 scores to get an overall score which represented how much I (theoretically) enjoyed that song. In theory, the highest scoring song would be streamed 100% every stream, would be streamed the most out of all songs, and would have no skips (which translates to 100% in each category).

I then created an additional view which divided the data into bins and outputted the top 10 songs according to differing numbers of streams.

The resulting datasets showing the top tracks and their scores are shown below as well as attached in the repository:

>
* **v3_SQL_Analysis_overall_scores**: The view stored as "overall_score"
    * This lists every song in the listening history with their scores in all 3 categories as well as the overall averaged score
* **v3_SQL_Analysis_BINNED_overall_scores**: The view stored as "top_10_per_bin"
    * This lists the top 10 songs within each bin (as defined in the earlier analysis)

<br>
<p align="center">
    <img src="images\Spotify_year_data_top10.PNG" height="300">
    <img src="images\v3_overallScore.PNG" height="200"><br>
    <em><b>Top:</b> The top 10 songs according to my original analysis<br>
    <b>Bottom:</b> The top 10 songs according to my SQL analysis. Note the difference in the scores display and the resulting tracks.
    </em>
</p>
<br>
<p align="center">
    <img src="images\v0_bin6.PNG" height="250">
    <img src="images\v0_bin3.PNG" height="250"><br>
    <em><b>Left</b>: The top 15 songs in bin 6 (>100 streams) according to my original analysis<br>
    <b>Right</b>: The top 15 songs in bin 3 (26-50 streams) according to my original analysis
    </em>
</p>
<p align="center">
    <img src="images\v3_bins6and3.PNG" height="350"><br>
    <em>The top 10 songs according to my SQL analysis from bins 6 and 3. Note the difference in the scores display and the resulting tracks.<br>
    <b>Bin 6</b>: Over 100 streams<br>
    <b>Bin 3</b>: 26-50 streams
    </em>
</p>

