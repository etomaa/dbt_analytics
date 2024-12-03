{% snapshot orders_status_snapshot %}                  ---# Defines a snapshot named "orders_status_snapshot"

--target_schema--       # Specifies the schema where the snapshot will be created in the data warehouse. 
--unique_key---         # The unique identifier for each record in the snapshot. Used to track changes.
--strategy---           # The snapshot strategy. In this case, it tracks changes based on a timestamp column.
--updated_at--          # Specifies the column containing the timestamp used to track updates.
{{
    config(
        target_schema='snapshots',                      
        unique_key='id',                               

        strategy='timestamp',                          
        updated_at='_etl_loaded_at',                   
        )
}}
select * from {{ source('jaffle_shop', 'orders') }}    ---# Queries the source table (orders) from the jaffle_shop source.

{% endsnapshot %}                                      ---# Marks the end of the snapshot definition.