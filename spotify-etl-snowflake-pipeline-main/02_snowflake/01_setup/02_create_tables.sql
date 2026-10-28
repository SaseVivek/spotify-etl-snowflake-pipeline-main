-- Purpose: Create the 3 core tables matching the transformation Lambda's CSV output.
-- Column names/order match the CSVs exactly for a clean COPY INTO later.

USE DATABASE MUSIC_CATALOG;
USE SCHEMA CATALOG_DATA;

-- Artists table
CREATE TABLE IF NOT EXISTS ARTISTS (
    artist_id      VARCHAR(50)   PRIMARY KEY,
    artist_name    VARCHAR(255),
    external_url   VARCHAR(500)
);

-- Albums table
CREATE TABLE IF NOT EXISTS ALBUMS (
    album_id       VARCHAR(50)   PRIMARY KEY,
    name           VARCHAR(255),
    release_date   DATE,
    total_tracks   NUMBER,
    url            VARCHAR(500)
);

-- Tracks table
CREATE TABLE IF NOT EXISTS TRACKS (
    song_id        VARCHAR(50)   PRIMARY KEY,
    song_name      VARCHAR(255),
    duration_ms    NUMBER,
    url            VARCHAR(500),
    popularity     NUMBER,
    song_added     TIMESTAMP_TZ
);