
CREATE OR REPLACE DATABASE snow_proj_db;

CREATE OR REPLACE SCHEMA snow_proj_db.tables_dbo;

create table snow_proj_db.tables_dbo.albums (
album_id string,
name string,
release_date date,
total_tracks int,
url string
);

create table snow_proj_db.tables_dbo.artists (
artist_id	string,
artist_name	string,
external_url string
);

create table snow_proj_db.tables_dbo.songs (
song_id	string,
song_name	string,
duration_ms	int,
url string,
popularity	int,
song_added	date,
album_id	string,
artist_id string
);

======================================
CREATE OR REPLACE SCHEMA snow_proj_db.file_formats_dbo;

CREATE OR REPLACE file format snow_proj_db.file_formats_dbo.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE;

======================================

CREATE OR REPLACE SCHEMA snow_proj_db.ext_stages_dbo;

CREATE OR REPLACE STAGE snow_proj_db.ext_stages_dbo.aws_stpy
    url='s3://spotify-pipeline-data-rittu'
    credentials=(aws_key_id='*****' aws_secret_key='*****');

    list @snow_proj_db.ext_stages_dbo.aws_stpy
===================================================
 
COPY INTO snow_proj_db.tables_dbo.albums
    FROM  @snow_proj_db.ext_stages_dbo.aws_stpy
file_format = (FORMAT_NAME=snow_proj_db.file_formats_dbo.csv_fileformat, FIELD_OPTIONALLY_ENCLOSED_BY='"')
files = ('transformed_data/album_data/album_transformed_*.csv')  
   #### ON_ERROR = continue;
    
select * from snow_proj_db.tables_dbo.albums;
-- truncate table snow_proj_db.tables_dbo.albums;

====================================================================
    
CREATE OR REPLACE SCHEMA snow_proj_db.pipes_dbo;

-- Snowpipe for Folder 1
CREATE OR REPLACE PIPE snow_proj_db.pipes_dbo.album_pipe_albums
AUTO_INGEST = TRUE
AS
COPY INTO snow_proj_db.tables_dbo.albums
FROM @snow_proj_db.ext_stages_dbo.aws_stpy
PATTERN = 'transformed_data/album_data.*'
FILE_FORMAT = (TYPE = 'CSV', FIELD_OPTIONALLY_ENCLOSED_BY='"');

desc pipe snow_proj_db.pipes_dbo.album_pipe_albums;

-- Snowpipe for Folder 2
CREATE OR REPLACE PIPE snow_proj_db.pipes_dbo.album_pipe_artists
AUTO_INGEST = TRUE
AS
COPY INTO snow_proj_db.tables_dbo.artists
FROM @snow_proj_db.ext_stages_dbo.aws_stpy
PATTERN = 'transformed_data/artist_data'
FILE_FORMAT = (TYPE = 'CSV', FIELD_OPTIONALLY_ENCLOSED_BY='"');

desc pipe snow_proj_db.pipes_dbo.album_pipe_artists;

-- Snowpipe for Folder 3
CREATE OR REPLACE PIPE snow_proj_db.pipes_dbo.album_pipe_songs
AUTO_INGEST = TRUE
AS
COPY INTO snow_proj_db.tables_dbo.songs
FROM @snow_proj_db.ext_stages_dbo.aws_stpy
PATTERN = 'transformed_data/songs_data/.*\.csv'
FILE_FORMAT = (TYPE = 'CSV', FIELD_OPTIONALLY_ENCLOSED_BY='"');

===============================================================

select * from snow_proj_db.tables_dbo.albums;

truncate table  snow_proj_db.tables_dbo.albums;

select * from snow_proj_db.tables_dbo.artists;

select * from snow_proj_db.tables_dbo.songs;

=============================================

DESC STAGE snow_proj_db.ext_stages_dbo.aws_stpy;


SHOW PIPES IN DATABASE snow_proj_db;

SHOW PIPES;

ALTER PIPE snow_proj_db.pipes_dbo.album_pipe_artists REFRESH;



