DECLARE @TableName NVARCHAR(255)
DECLARE @SchemaName NVARCHAR(255)
DECLARE @IndexName NVARCHAR(255)
DECLARE @FragPercent DECIMAL

DECLARE IndexCursor CURSOR FOR
    SELECT
        OBJECT_SCHEMA_NAME(ips.[object_id]) as SchemaName,
        OBJECT_NAME(ips.[object_id]) as TableName,
        si.name as IndexName,
        ips.avg_fragmentation_in_percent
    FROM
        sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    JOIN
        sys.indexes si ON ips.[object_id] = si.[object_id]
        AND ips.index_id = si.index_id
    WHERE
        ips.avg_fragmentation_in_percent > 10 -- Consider indexes with more than 10% fragmentation
    ORDER BY
        ips.avg_fragmentation_in_percent DESC

OPEN IndexCursor

FETCH NEXT FROM IndexCursor INTO @SchemaName, @TableName, @IndexName, @FragPercent

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @FragPercent > 30
    BEGIN
        EXEC('ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD')
    END
    ELSE
    BEGIN
        EXEC('ALTER INDEX [' + @IndexName + '] ON[' + @SchemaName + '].[' + @TableName + '] REORGANIZE')
    END

    FETCH NEXT FROM IndexCursor INTO @SchemaName, @TableName, @IndexName, @FragPercent
END

CLOSE IndexCursor
DEALLOCATE IndexCursor
