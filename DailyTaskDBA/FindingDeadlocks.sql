SELECT
    XEvent.query('(data/value/deadlock)[1]') AS DeadlockGraph
FROM
    (SELECT
         XEvent.query('.') AS XEvent
     FROM
         (SELECT
              CAST(target_data AS XML) AS TargetData
          FROM
              sys.dm_xe_session_targets st
          JOIN
              sys.dm_xe_sessions s ON s.address = st.event_session_address
          WHERE
              name = 'system_health') AS Data
     CROSS APPLY
         TargetData.nodes ('//RingBufferTarget/event') AS XEventData (XEvent)
     ) AS src
WHERE
    XEvent.value('(@name)[1]', 'varchar(4000)') = 'xml_deadlock_report';
