WITH PortalEvents as
(
    SELECT 
        evtl.userid USERNAME,
        evtl.EVENTTIME,
        DECODE(LOWER(evtl.EVENTTYPENAME), 'generate', 'Login', 'delete', 'Logout', evtl.EVENTTYPENAME) ACTION,
        evtl.OBJECTTYPENAME OBJECTTYPE,
        evtl.OBJECTNAME,
        DECODE(LOWER(evtl.EVENTTYPENAME), 'generate', 'Login to Portal', 'delete', 'Logout of Portal', evtl.EVENTTYPENAME) DESCRIPTION,
        evtl.REQUESTSOURCE IP_ADDRESS
    FROM 
        csi_eventlog@tc_link evtl
    WHERE 
        evtl.eventtypename IS NOT NULL
        AND evtl.EVENTTYPENAME IN('generate','delete')
        AND evtl.eventtime >= TO_DATE('20180608_000000','YYYYMMDD_HH24MISS')
        AND evtl.eventtime < TO_DATE('20180608_160000','YYYYMMDD_HH24MISS')
)
, PortalLogins as 
(
    SELECT * 
    FROM PortalEvents
    WHERE ACTION='Login'
    ORDER  BY EVENTTIME
)
, PortalEvents2 as
(
    SELECT 
        pe.USERNAME,
        pe.EVENTTIME,
        pe.ACTION,
        pe.OBJECTTYPE,
        pe.OBJECTNAME,
        pe.DESCRIPTION,
        CASE WHEN pe.DESCRIPTION = 'Logout of Portal' THEN (SELECT pl.IP_ADDRESS FROM PortalLogins pl WHERE pe.EVENTTIME > pl.EVENTTIME AND pe.USERNAME = pl.USERNAME AND ROWNUM=1) ELSE pe.IP_ADDRESS END IP_ADDRESS
    FROM PortalEvents pe
)
,  CommissionsEvents as
(
    SELECT 
        audl.USERID USERNAME,
        audl.eventdate EVENTTIME,
        audl.EVENTTYPE ACTION,
        audl.OBJECTTYPE,
        audl.OBJECTNAME,
        audl.EVENTDESCRIPTION DESCRIPTION,
        (SELECT IP_ADDRESS FROM PortalLogins WHERE audl.eventdate > EVENTTIME AND audl.USERID = USERNAME AND ROWNUM=1) IP_ADDRESS
    FROM 
        cs_auditlog@tc_link audl
    WHERE 
        audl.EVENTTYPE IS NOT NULL
        AND audl.EVENTTYPE IN('Login','Logout')
        AND audl.eventdate >= TO_DATE('20180608_000000','YYYYMMDD_HH24MISS')
        AND audl.eventdate < TO_DATE('20180608_160000','YYYYMMDD_HH24MISS')
)
SELECT USERNAME, EVENTTIME, TRANSLATE(ACTION using nchar_cs) ACTION, OBJECTTYPE, OBJECTNAME, TRANSLATE(DESCRIPTION using nchar_cs) DESCRIPTION, IP_ADDRESS
FROM CommissionsEvents 
UNION ALL
SELECT USERNAME, EVENTTIME, TRANSLATE(ACTION using nchar_cs) ACTION, OBJECTTYPE, OBJECTNAME, TRANSLATE(DESCRIPTION using nchar_cs) DESCRIPTION, IP_ADDRESS
FROM PortalEvents2
ORDER BY EVENTTIME
;