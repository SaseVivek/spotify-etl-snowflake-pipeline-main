# Spotify ETL & Snowflake Analytics Pipeline

An end-to-end, serverless data engineering project that extracts music catalog metadata from the Spotify Web API, transforms raw JSON data using Python and AWS Lambda, and automatically loads structured datasets into Snowflake for analytics.


## Table of Contents

- [Project Overview](#project-overview)
- [Business Objectives](#business-objectives)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Data Flow](#data-flow)
- [Snowflake Data Warehouse](#snowflake-data-warehouse)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup and Deployment](#setup-and-deployment)
- [Data Quality and Validation](#data-quality-and-validation)
- [Design Decisions and Challenges](#design-decisions-and-challenges)
- [Known Limitations](#known-limitations)
- [Security Considerations](#security-considerations)
- [Future Enhancements](#future-enhancements)
- [Learning Outcomes](#learning-outcomes)
- [License](#license)

## Project Overview

The Spotify ETL & Snowflake Analytics Pipeline demonstrates how to build an automated data engineering workflow using Python, AWS serverless services, and Snowflake.

The pipeline extracts artist, album, and track metadata from the Spotify Web API. AWS Lambda functions process the data, Amazon S3 stores raw and transformed files, and Snowpipe loads newly created files into Snowflake.

Amazon EventBridge schedules the extraction process, while Amazon S3 event notifications and Amazon SQS support event-driven processing and automated ingestion.

The resulting Snowflake tables provide a structured foundation for SQL-based analysis of music catalog data.

### Key Features

- **Automated extraction:** Retrieves music catalog metadata through the Spotify Web API.
- **Serverless processing:** Uses AWS Lambda for extraction and transformation.
- **Scheduled execution:** Uses Amazon EventBridge to trigger daily extraction.
- **Data lake storage:** Separates raw and transformed data in Amazon S3.
- **Data transformation:** Uses Python and pandas to clean, flatten, and deduplicate JSON records.
- **Event-driven ingestion:** Uses S3 event notifications, Amazon SQS, and Snowpipe.
- **Cloud data warehousing:** Stores structured artist, album, and track datasets in Snowflake.
- **Data validation:** Includes SQL scripts for checking loaded row counts.
- **Scalable architecture:** Uses managed cloud services instead of continuously running servers.

## Business Objectives

The project focuses on implementing an automated and maintainable data pipeline that:

1. Extracts music metadata from an external API.
2. Converts raw API responses into structured, analytics-ready datasets.
3. Stores data in separate raw and transformed storage zones.
4. Automates data movement between processing and storage layers.
5. Loads new files into Snowflake with minimal manual intervention.
6. Organizes music catalog data into relational tables for SQL analysis.
7. Validates ingestion and identifies potential data quality issues.

## Architecture

### Architecture Diagram

![Spotify ETL and Snowflake Architecture](04_docs/architecture-diagram.png)

View the [architecture diagram](https://github.com/gauravshinde17/spotify-etl-snowflake-pipeline/blob/main/04_docs/architecture-diagram.png).

### High-Level Architecture

```text
                    Spotify Web API
                           |
                           v
                    Python / Spotipy
                           |
                           v
                Amazon EventBridge
                  (Daily Schedule)
                           |
                           v
                  AWS Lambda Function
                     (Extraction)
                           |
                           v
                    Amazon S3
                     (Raw Data)
                           |
                     S3 Event Trigger
                           |
                           v
                  AWS Lambda Function
                   (Transformation)
                           |
                           v
                    Amazon S3
                (Transformed Data)
                           |
                  S3 Event Notifications
                           |
                           v
                    Amazon SQS
                  (Event Messaging)
                           |
                           v
                      Snowpipe
                    (Auto-Ingest)
                           |
                           v
                       Snowflake
                     MUSIC_CATALOG
                           |
                           v
                 SQL Analytics and Reporting
```

The architecture separates extraction, transformation, storage, and ingestion into independent stages. This separation makes individual components easier to maintain and troubleshoot.

## Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Data source | Spotify Web API | Provides artist, album, and track metadata |
| API integration | Python, Spotipy | Authenticates and retrieves API data |
| Extraction | AWS Lambda | Executes serverless data extraction |
| Scheduling | Amazon EventBridge | Triggers daily pipeline execution |
| Raw storage | Amazon S3 | Stores extracted JSON data |
| Transformation | Python, pandas | Cleans, flattens, and deduplicates records |
| Processing | AWS Lambda | Executes transformation logic |
| Event handling | Amazon S3 Event Notifications | Triggers downstream processing |
| Messaging | Amazon SQS | Delivers file-arrival notifications for ingestion |
| Data ingestion | Snowpipe | Automatically loads new files |
| Data warehouse | Snowflake | Stores structured datasets |
| Query language | SQL | Creates tables and validates loaded data |
| Access control | AWS IAM | Controls access to AWS resources |
| Documentation | Markdown, PowerPoint | Documents the architecture and implementation |

## Data Flow

### 1. Data Extraction

The extraction Lambda function retrieves music catalog metadata from the Spotify Web API using Python and the Spotipy library.

Authentication uses the Client Credentials Flow, which supports application-level API access without requiring an end-user login.

The extracted data includes information associated with:

- Artists
- Albums
- Tracks

The extraction process is scheduled through Amazon EventBridge.

### 2. Raw Data Storage

The extracted API responses are stored in an Amazon S3 raw-data location.

Keeping the original data separate from transformed data helps preserve the source representation and supports troubleshooting or reprocessing.

### 3. Data Transformation

An S3 event triggers the transformation Lambda function when new raw data is available.

The transformation logic uses pandas to:

- Parse JSON responses.
- Flatten nested data structures.
- Clean and standardize fields.
- Organize records into structured datasets.
- Deduplicate records within the transformation process.
- Export the resulting datasets as CSV files.

The transformed files are organized into separate locations for artists, albums, and tracks.

### 4. Transformed Data Storage

The structured CSV files are written to dedicated Amazon S3 locations.

This transformed-data layer provides files in a format suitable for loading into Snowflake.

### 5. Event-Driven Ingestion

Amazon S3 event notifications send file-arrival messages to the appropriate Snowpipe notification channels through Amazon SQS.

Snowpipe uses these notifications to identify newly available files and initiate ingestion.

This eliminates the need to manually execute a `COPY INTO` command for every new batch of files.

### 6. Snowflake Loading

Snowflake stores the ingested datasets in the `MUSIC_CATALOG` database and `CATALOG_DATA` schema.

The pipeline maintains three primary tables:

- `ARTISTS`
- `ALBUMS`
- `TRACKS`

These tables provide a structured foundation for SQL queries, data exploration, and downstream reporting.

### 7. Data Validation

SQL validation scripts check row counts after ingestion to help verify that the data-loading process has populated the target tables.

Row-count validation is a useful baseline check, although it does not independently guarantee that every record is accurate, unique, or complete.

## Snowflake Data Warehouse

### Database Objects

| Object Type | Name | Purpose |
|---|---|---|
| Database | `MUSIC_CATALOG` | Main music catalog database |
| Schema | `CATALOG_DATA` | Organizes the catalog tables |
| Table | `ARTISTS` | Stores artist metadata |
| Table | `ALBUMS` | Stores album metadata |
| Table | `TRACKS` | Stores track metadata |
| Warehouse | `COMPUTE_WH` | Provides compute resources for queries and loading |
| File format | `CSV_FORMAT` | Defines CSV parsing settings |
| External stage | `ARTISTS_STAGE` | References artist data files in S3 |
| External stage | `ALBUMS_STAGE` | References album data files in S3 |
| External stage | `TRACKS_STAGE` | References track data files in S3 |
| Snowpipe | `ARTISTS_PIPE` | Automates artist data ingestion |
| Snowpipe | `ALBUMS_PIPE` | Automates album data ingestion |
| Snowpipe | `TRACKS_PIPE` | Automates track data ingestion |

The Snowflake setup scripts create the required database objects, configure the external stages, define loading operations, and establish Snowpipe ingestion.

### Example Analytical Queries

The following example queries illustrate how the loaded catalog tables can be explored. Adjust column names to match the actual table definitions.

**1. Check the number of records in each table**

```sql
SELECT 'ARTISTS' AS TABLE_NAME, COUNT(*) AS TOTAL_RECORDS
FROM MUSIC_CATALOG.CATALOG_DATA.ARTISTS

UNION ALL

SELECT 'ALBUMS', COUNT(*)
FROM MUSIC_CATALOG.CATALOG_DATA.ALBUMS

UNION ALL

SELECT 'TRACKS', COUNT(*)
FROM MUSIC_CATALOG.CATALOG_DATA.TRACKS;
```

**2. Inspect artist records**

```sql
SELECT *
FROM MUSIC_CATALOG.CATALOG_DATA.ARTISTS
LIMIT 10;
```

**3. Inspect album records**

```sql
SELECT *
FROM MUSIC_CATALOG.CATALOG_DATA.ALBUMS
LIMIT 10;
```

**4. Inspect track records**

```sql
SELECT *
FROM MUSIC_CATALOG.CATALOG_DATA.TRACKS
LIMIT 10;
```

**5. Identify duplicate artist identifiers**

Replace `ARTIST_ID` with the actual unique identifier column if named differently.

```sql
SELECT
    ARTIST_ID,
    COUNT(*) AS RECORD_COUNT
FROM MUSIC_CATALOG.CATALOG_DATA.ARTISTS
GROUP BY ARTIST_ID
HAVING COUNT(*) > 1;
```

These are example queries for exploration and validation, not claims about specific query results or catalog statistics.

## Project Structure

```text
spotify-etl-snowflake-pipeline/
│
├── .env.example
├── .gitignore
├── README.md
├── requirements.txt
│
├── 01_lambda/
│   ├── extraction/
│   │   └── lambda_function.py
│   │
│   └── transformation/
│       └── lambda_function.py
│
├── 02_snowflake/
│   ├── 01_setup/
│   │   ├── 01_create_database_schema.sql
│   │   ├── 02_create_tables.sql
│   │   └── 03_create_stage_with_credentials.sql
│   │
│   ├── 02_load/
│   │   ├── 04_test_copy_into.sql
│   │   └── 05_create_snowpipes.sql
│   │
│   └── 03_validation/
│       └── 06_row_count_checks.sql
│
├── 03_notebooks/
│   └── S_Data_Pipeline.ipynb
│
└── 04_docs/
    ├── architecture-diagram.pptx
    └── architecture-diagram.png
```

## Prerequisites

Before deploying the pipeline, ensure you have access to the following:

- Python 3.x compatible with your chosen AWS Lambda runtime.
- A Spotify Developer account and registered application.
- AWS account with permissions to configure Lambda, S3, EventBridge, SQS, and IAM.
- A Snowflake account with permissions to create databases, schemas, tables, stages, and Snowpipes.
- Git for cloning and managing the repository.
- Required Python dependencies listed in `requirements.txt`.

AWS and Snowflake resources may incur charges depending on usage, configuration, and account entitlements. Review applicable pricing before deployment.

## Setup and Deployment

### Step 1: Clone the Repository

```bash
git clone https://github.com/gauravshinde17/spotify-etl-snowflake-pipeline.git

cd spotify-etl-snowflake-pipeline
```

If you are creating your own version, replace the repository URL with your repository's URL.

### Step 2: Configure Spotify API Credentials

1. Open the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard).
2. Create or select an application.
3. Obtain the application client ID and client secret.
4. Configure the credentials through environment variables or an appropriate secrets-management mechanism.

Use `.env.example` as a reference for the required configuration variables.

Do not commit real credentials, access tokens, or secrets to GitHub.

### Step 3: Install Python Dependencies

Create and activate a virtual environment if you are running the project locally.

```bash
python -m venv .venv
```

Activate it on Windows:

```powershell
.venv\Scripts\activate
```

Activate it on macOS or Linux:

```bash
source .venv/bin/activate
```

Install the project dependencies:

```bash
pip install -r requirements.txt
```

The Lambda deployment packages must include the dependencies required by the corresponding functions.

### Step 4: Configure Amazon S3

Create the S3 bucket and configure separate locations for raw and transformed data.

A logical layout could look like this:

```text
s3://your-bucket/
├── raw_data/
│   ├── artists/
│   ├── albums/
│   └── tracks/
│
└── transformed_data/
    ├── artists/
    ├── albums/
    └── tracks/
```

This is an illustrative layout; use the actual bucket names and prefixes configured in your Lambda functions and Snowflake stages.

### Step 5: Deploy AWS Lambda Functions

Deploy the two functions located in `01_lambda/`:

- `extraction/lambda_function.py`
- `transformation/lambda_function.py`

Configure their environment variables, execution roles, timeouts, and memory settings as required.

The extraction function needs permission to write raw data to S3. The transformation function needs permission to read raw data and write transformed files.

Configure the S3 event trigger to invoke transformation after new raw data is written.

### Step 6: Configure EventBridge Scheduling

Create an Amazon EventBridge scheduled rule to invoke the extraction Lambda function daily.

Choose the required schedule and confirm the rule has permission to invoke the function.

Verify the configured schedule and function logs before relying on automated execution.

### Step 7: Create Snowflake Objects

Run the SQL scripts in the following order:

1. `01_create_database_schema.sql`
2. `02_create_tables.sql`
3. `03_create_stage_with_credentials.sql`

Review the SQL and replace placeholders with the actual database settings, S3 paths, and required credentials.

The scripts establish the database, schema, target tables, file format, and external stages.

### Step 8: Test File Loading

Execute:

```text
02_snowflake/02_load/04_test_copy_into.sql
```

This script is intended to test loading files into Snowflake using `COPY INTO`.

Confirm that the file paths, stage definitions, CSV settings, and target table columns are aligned.

### Step 9: Configure Snowpipe

Execute:

```text
02_snowflake/02_load/05_create_snowpipes.sql
```

Create and configure the three Snowpipes for the artists, albums, and tracks datasets.

Configure the relevant S3 event notifications and Amazon SQS notification channels using the notification details provided by Snowflake.

Ensure the notification configuration targets the appropriate Snowpipe and transformed-data prefix.

### Step 10: Validate the Pipeline

Execute:

```text
02_snowflake/03_validation/06_row_count_checks.sql
```

Inspect the results and confirm that the expected target tables contain data.

For end-to-end validation, also review AWS Lambda logs, S3 object creation, SQS notification delivery, and Snowpipe load history.

## Data Quality and Validation

The pipeline includes transformation and validation steps intended to improve data consistency.

| Area | Approach |
|---|---|
| JSON processing | Parse and flatten API responses |
| Data standardization | Clean and structure extracted fields |
| Duplicate handling | Deduplicate records during transformation and use SQL checks to identify remaining duplicates |
| File format | Export transformed datasets as CSV |
| Ingestion verification | Validate loaded table row counts |
| Pipeline troubleshooting | Inspect Lambda execution logs and Snowflake load history |

**Important:** Deduplication during transformation does not automatically guarantee uniqueness across multiple extraction runs. Warehouse-level controls are required to handle records repeated across batches reliably.

## Design Decisions and Challenges

### 1. Credential-Based External Stage

The project uses a credential-based external stage rather than a Snowflake storage integration.

During implementation, the Snowflake deployment's AWS region presented an `sts:AssumeRole` issue when configuring the storage integration. The credential-based approach was selected as a workaround for the project's environment.

This approach allows Snowflake to access the configured S3 data location using AWS credentials. However, it requires careful key management and rotation.

For production environments, a supported storage integration with an appropriate IAM trust relationship is generally preferable because it avoids embedding long-lived AWS access keys in the stage configuration.

### 2. Least-Privilege IAM Permissions

AWS IAM permissions are scoped according to the responsibilities of each component.

For example:

- The extraction function requires permission to write raw objects to S3.
- The transformation function requires permission to read source objects and write transformed objects.
- Snowflake's S3 access credentials require read access to the relevant bucket locations.

The project encountered an S3 permission issue in which the Lambda execution role lacked `s3:PutObject`. Granting the specific required permission resolved that class of access issue.

This highlights the importance of matching IAM policies to actual resource operations instead of granting unnecessarily broad permissions.

### 3. Event-Driven Processing

The architecture uses scheduled extraction followed by event-driven transformation and ingestion.

Event-driven processing reduces the need for manually coordinating each stage. However, production deployments should also account for retries, duplicate notifications, partial failures, and monitoring of failed executions.

### 4. Snowpipe Ingestion and Duplicate Records

Snowpipe tracks file ingestion, but file-level load tracking is not equivalent to row-level deduplication.

If the same logical artist or track is emitted in multiple files, duplicate records can appear in the destination tables. Declaring a primary key does not, by itself, enforce uniqueness in standard Snowflake tables.

The project identifies duplicates through SQL checks and a `ROW_NUMBER()`-based deduplication pass.

A stronger design would load incoming files into staging tables and use `MERGE` statements to insert new records and update existing records based on stable business keys.

## Known Limitations

- **Row-level uniqueness:** Duplicate records may be inserted across separate extraction runs.
- **Credential rotation:** Credential-based stages require an explicit access-key rotation process.
- **Validation scope:** Row-count checks alone do not establish full data correctness.
- **Operational monitoring:** A production deployment would benefit from centralized alerts, freshness checks, and failure notifications.
- **Metadata history:** The current design does not implement a complete history of changes to artist, album, or track metadata.
- **API constraints:** Extraction is subject to Spotify API availability, authentication requirements, rate limits, and applicable API policies.

These limitations provide clear opportunities for strengthening the pipeline for production use.

## Security Considerations

- Store Spotify and AWS credentials outside source code.
- Keep `.env` files and other secret-bearing files out of version control.
- Use dedicated IAM roles and narrowly scoped permissions for Lambda functions.
- Restrict Snowflake's S3 access to the required bucket and prefixes.
- Rotate access keys and revoke credentials that are no longer required.
- Avoid logging client secrets, access tokens, or other sensitive configuration values.
- Review Spotify API terms and applicable data usage requirements before deploying or redistributing collected data.

## Future Enhancements

The following improvements are planned or potential extensions to the current design:

- [ ] Replace direct `COPY INTO` loading with staging tables and `MERGE`-based upserts.
- [ ] Introduce robust idempotency and cross-batch deduplication.
- [ ] Evaluate Apache Airflow or another orchestrator for more complex dependencies.
- [ ] Implement Slowly Changing Dimensions (SCD) to track metadata changes over time.
- [ ] Add data freshness checks and pipeline SLA monitoring.
- [ ] Configure centralized logging, failure alerts, and retry handling.
- [ ] Add automated tests for extraction, transformation, and data validation.
- [ ] Improve secret management and migrate to a supported Snowflake storage integration where possible.
- [ ] Add analytics views for artist, album, and track catalog exploration.

## Learning Outcomes

This project provides practical experience with:

- Building an end-to-end ETL pipeline using Python.
- Integrating with a third-party REST API.
- Transforming semi-structured JSON into structured datasets.
- Deploying serverless data-processing functions on AWS Lambda.
- Automating workflows using Amazon EventBridge and S3 events.
- Using Amazon S3 as a raw and transformed data lake.
- Configuring event-driven ingestion with SQS and Snowpipe.
- Creating Snowflake databases, schemas, tables, and external stages.
- Writing SQL scripts for data loading and validation.
- Troubleshooting IAM permissions and cloud-service integrations.
- Identifying data quality, deduplication, and operational reliability challenges.

## License

Choose and add an appropriate open-source license before distributing this repository. If no license file is included, the repository should not be assumed to grant permission to reuse, modify, or redistribute its contents.

---

**Project:** Spotify ETL & Snowflake Analytics Pipeline

**Core technologies:** Python, Spotipy, pandas, AWS Lambda, Amazon S3, Amazon EventBridge, Amazon SQS, Snowpipe, Snowflake, SQL

**Focus:** Automated data extraction, serverless ETL, event-driven ingestion, and cloud data warehousing.
