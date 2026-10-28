-- Purpose: Sanity-check the loaded data — row counts, duplicates, nulls on key columns.

USE DATABASE MUSIC_CATALOG;
USE SCHEMA CATALOG_DATA;

-- ============================================
-- 1. Row counts across all 3 tables
-- ============================================
SELECT 'ARTISTS' AS table_name, COUNT(*) AS row_count FROM ARTISTS
UNION ALL
SELECT 'ALBUMS', COUNT(*) FROM ALBUMS
UNION ALL
SELECT 'TRACKS', COUNT(*) FROM TRACKS;

-- ============================================
-- 2. Duplicate primary key checks
-- ============================================
SELECT artist_id, COUNT(*) AS dup_count
FROM ARTISTS
GROUP BY artist_id
HAVING COUNT(*) > 1;

SELECT album_id, COUNT(*) AS dup_count
FROM ALBUMS
GROUP BY album_id
HAVING COUNT(*) > 1;

SELECT song_id, COUNT(*) AS dup_count
FROM TRACKS
GROUP BY song_id
HAVING COUNT(*) > 1;

-- ============================================
-- 3. Null checks on critical columns
-- ============================================
SELECT COUNT(*) AS null_artist_names
FROM ARTISTS
WHERE artist_name IS NULL;

SELECT COUNT(*) AS null_album_names
FROM ALBUMS
WHERE name IS NULL;

SELECT COUNT(*) AS null_song_names
FROM TRACKS
WHERE song_name IS NULL;

