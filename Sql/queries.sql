
SELECT
    r.service_type,
    SUM(GREATEST(d.actual_days - d.promised_days, 0)) AS total_delay_days
FROM deliveries AS d
JOIN routes AS r
    ON d.route_id = r.route_id
GROUP BY r.service_type
ORDER BY total_delay_days DESC;



SELECT
    d.route_id,
    r.route_name,
    SUM(GREATEST(d.actual_days - d.promised_days, 0)) AS total_delay_days
FROM deliveries AS d
JOIN routes AS r
    ON d.route_id = r.route_id
GROUP BY d.route_id, r.route_name
HAVING SUM(GREATEST(d.actual_days - d.promised_days, 0)) > 8
ORDER BY total_delay_days DESC;



SELECT
    d.hub,
    SUM(GREATEST(d.actual_days - d.promised_days, 0)) AS total_delay_days
FROM deliveries AS d
GROUP BY d.hub
ORDER BY total_delay_days DESC, d.hub ASC
LIMIT 2;


.
SELECT
    COUNT(*) AS unmatched_route_count
FROM deliveries AS d
LEFT JOIN routes AS r
    ON d.route_id = r.route_id
WHERE r.route_id IS NULL;



SELECT
    (SELECT COUNT(*) FROM deliveries) AS delivery_row_count,
    (SELECT COUNT(*) FROM routes) AS route_row_count;
