{{ 
    config(materialized='table') 
}}

WITH 
  source AS (
    SELECT *
    FROM {{ source('lakehouse', 'titanic') }}
  ),

  cleaned AS (
    SELECT
      _airbyte_raw_id AS id,
      CAST(passengerid AS INTEGER) AS passenger_id,
      CAST(age AS INTEGER) AS age,
      sex,
      fare,
      name,
      cabin,
      CAST(parch AS INTEGER) AS parents_children_aboard,
      sibsp > 0 AS siblings_spouses_aboard, -- Simplified boolean logic
      CAST(pclass AS INTEGER) AS ticket_class,
      ticket,
      embarked,
      CASE embarked
        WHEN 'S' THEN 'Southampton'
        WHEN 'C' THEN 'Cherbourg'
        WHEN 'Q' THEN 'Queenstown'
        ELSE 'Unknown'
      END AS embarked_port,
      survived > 0 AS survived, -- Simplified boolean logic
      from_unixtime(_airbyte_extracted_at / 1000.0) AS synced_at, -- Milliseconds to seconds
      'airbyte' AS synced_by
    FROM source
  )

SELECT 
  *,
  current_timestamp AS transformed_at, -- Trino uses no parentheses
  'dbt' AS transformed_by
FROM cleaned