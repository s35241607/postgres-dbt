# Project Overview

This is a dbt (data build tool) project that uses PostgreSQL as the data warehouse. The project is configured to transform data from raw sources into a structured format, ready for analysis.

## Key Technologies

*   **dbt:** The core transformation tool used in this project.
*   **PostgreSQL:** The target data warehouse.
*   **Python:** Used for scripting and running dbt.

## Project Structure

The project follows a standard dbt structure:

*   `models/`: Contains the dbt models, which are SQL `SELECT` statements that define the transformations.
    *   `staging/`: Models that clean and standardize the raw data.
    *   `intermediate/`: Models that perform intermediate transformations.
    *   `marts/`: Models that represent the final, user-facing data models.
*   `seeds/`: Contains CSV files that are loaded as tables into the data warehouse.
*   `tests/`: Contains dbt tests to ensure data quality.
*   `macros/`: Contains dbt macros, which are reusable pieces of SQL code.
*   `dbt_project.yml`: The main configuration file for the dbt project.
*   `packages.yml`: Declares the dbt packages used in the project. This project uses `dbt-labs/codegen`.
*   `pyproject.toml`: Defines the Python dependencies, including `dbt-postgres`.

## Building and Running

*   **Install dependencies:**
    ```bash
    pip install -e .
    dbt deps
    ```
*   **Run the dbt models:**
    ```bash
    dbt run
    ```
*   **Test the dbt models:**
    ```bash
    dbt test
    ```
*   **Load seed data:**
    ```bash
    dbt seed
    ```

## Development Conventions

*   Models are organized into `staging`, `intermediate`, and `marts` directories.
*   Data quality is ensured through dbt tests.
*   The `dbt-labs/codegen` package is available for generating dbt models.
