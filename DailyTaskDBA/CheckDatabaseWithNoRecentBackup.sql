WITH LastBackup AS (
    SELECT
        database_name,
        MAX(backup_finish_date) AS last_backup
    FROM
        msdb.dbo.backupset
    GROUP BY
        database_name
)
SELECT
    name AS [Database]
FROM
    sys.databases db
LEFT JOIN
    LastBackup lb ON db.name = lb.database_name
WHERE
    db.state = 0 -- Only consider online databases
    AND (
        lb.last_backup IS NULL
        OR DATEDIFF(hour, lb.last_backup, GETDATE()) > 48 -- Consider as not recent if more than 48 hours old
    )
ORDER BY
    db.name;
