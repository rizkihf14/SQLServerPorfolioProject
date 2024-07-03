SELECT
    dm_mid.database_id,
    dm_mid.[object_id],
    dm_migs.avg_total_user_cost * (dm_migs.avg_user_impact / 100.0) * (dm_migs.user_seeks + dm_migs.user_scans) AS improvement_measure,
    'CREATE INDEX missing_index_' + CONVERT (varchar, dm_mid.index_group_handle) + '_' + CONVERT (varchar, dm_mid.index_handle) + ' ON ' + dm_mid.statement + ' (' + ISNULL (dm_mic.column_store, '') + ')' + ISNULL (dm_mic.equality_columns,'')
    + CASE WHEN dm_mic.equality_columns IS NOT NULL AND dm_mic.inequality_columns IS NOT NULL THEN ',' ELSE '' END + ISNULL (dm_mic.inequality_columns, '') + ')' + ISNULL (' INCLUDE (' + dm_mic.included_columns + ')', '') AS create_index_statement,
    dm_migs.*,
    dm_mid.database_id,
    dm_mid.[object_id]
FROM
    sys.dm_db_missing_index_groups dm_mig
    INNER JOIN sys.dm_db_missing_index_group_stats dm_migs ON dm_migs.group_handle = dm_mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details dm_mid ON dm_mig.index_handle = dm_mid.index_handle
    INNER JOIN (
        SELECT
            index_handle,
            STRING_AGG(column_name, ', ') WITHIN GROUP (ORDER BY column_name) AS column_store
        FROM sys.dm_db_missing_index_columns (NULL)
        WHERE column_usage = 'STORE'
        GROUP BY index_handle
    ) AS dm_mic_store ON dm_mid.index_handle = dm_mic_store.index_handle
    LEFT JOIN (
        SELECT
            index_handle,
            STRING_AGG(column_name, ', ') WITHIN GROUP (ORDER BY column_name) AS equality_columns,
            STRING_AGG(column_name, ', ') WITHIN GROUP (ORDER BY column_name) AS inequality_columns,
            STRING_AGG(column_name, ', ') WITHIN GROUP (ORDER BY column_name) AS included_columns
        FROM sys.dm_db_missing_index_columns (NULL)
        WHERE column_usage = 'EQUALITY' OR column_usage = 'INEQUALITY' OR column_usage = 'INCLUDE'
        GROUP BY index_handle
    ) AS dm_mic ON dm_mid.index_handle = dm_mic.index_handle
WHERE
    dm_mid.database_id = DB_ID()
ORDER BY
    improvement_measure DESC
