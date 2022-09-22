# Spotify Analysis

I have used Spotify since 2016/2017, and for most of those years, I gave no second thought to my listening history. Only when the first Spotify Unwrapped was released did I realize the scale of the data that Spotify was tracking about my listening history. However, each year, Spotify Unwrapped surprises me less and less - by the end of the year, I typically have a very good idea of what my top genres/tracks/artists are. When I discovered that I could request my listening history, I decided to challenge myself to write code to find my favorite genres/tracks/artists in the year so far.

This was my first data analysis project - it was done completely within Python via Jupyter Notebooks. It was also a way for me to play with various tools offered in Python, so this initial iteration is admittedly a bit disorganized. As time passed and I developed my skills in related areas, I would periodically return to this project to improve various aspects, and so this project is presented as successive, often stand-alone iterations.

## Understanding the data

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

>**Number of Streams**
* The number of times a song was streamed relative to other songs in the bin
>**Average Streamtime**
* The average percentage of a song that was streamed 
>**Number of Skips**
* Each song was penalized for the number of skips at various stages of the song

The implementation of these metrics was a bit messy in this iteration and was simplified in my later SQL iteration, but it resulted in a successful algorithm which ranked my listening history at various numbers of streams. 