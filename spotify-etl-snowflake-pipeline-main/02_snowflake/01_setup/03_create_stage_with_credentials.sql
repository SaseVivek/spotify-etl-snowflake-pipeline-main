-- Purpose: Define the CSV file format and create 3 external stages
-- pointing directly at S3 folders using IAM credentials (no storage integration).

USE DATABASE MUSIC_CATALOG;
USE SCHEMA CATALOG_DATA;

-- File format: matches how your transformation Lambda writes CSVs
-- (header row present, standard comma delimiter)
CREATE FILE FORMAT IF NOT EXISTS CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Stage for artist data
CREATE OR REPLACE STAGE ARTISTS_STAGE
    URL = 's3://spotify-etl-project-gauravs/transformed_data/artist_data/'
    CREDENTIALS = (AWS_KEY_ID = '<YOUR_ACCESS_KEY_ID>' AWS_SECRET_KEY ='<YOUR_SECRET_ACCESS_KEY>')
    FILE_FORMAT = CSV_FORMAT;

-- Stage for album data
CREATE OR REPLACE STAGE ALBUMS_STAGE
    URL = 's3://spotify-etl-project-gauravs/transformed_data/album_data/'
    CREDENTIALS = (AWS_KEY_ID = '<YOUR_ACCESS_KEY_ID>' AWS_SECRET_KEY ='<YOUR_SECRET_ACCESS_KEY>')
    FILE_FORMAT = CSV_FORMAT;

-- Stage for track/songs data
CREATE OR REPLACE STAGE TRACKS_STAGE
    URL = 's3://spotify-etl-project-gauravs/transformed_data/songs_data/'
    CREDENTIALS = (AWS_KEY_ID = '<YOUR_ACCESS_KEY_ID>' AWS_SECRET_KEY ='<YOUR_SECRET_ACCESS_KEY>')
    FILE_FORMAT = CSV_FORMAT;


LIST @ARTISTS_STAGE;
LIST @ALBUMS_STAGE;
LIST @TRACKS_STAGE;

