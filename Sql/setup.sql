

DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS routes;

CREATE TABLE routes (
    route_id VARCHAR(10) PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL,
    service_type VARCHAR(30) NOT NULL
);

CREATE TABLE deliveries (
    record_id INTEGER PRIMARY KEY,
    month VARCHAR(10) NOT NULL,
    route_id VARCHAR(10) NOT NULL,
    hub VARCHAR(50) NOT NULL,
    promised_days INTEGER NOT NULL,
    actual_days INTEGER NOT NULL,
    CONSTRAINT fk_deliveries_route
        FOREIGN KEY (route_id)
        REFERENCES routes(route_id)
);



INSERT INTO routes (route_id, route_name, service_type) VALUES
('R1', 'Metro Link', 'Express'),
('R2', 'City Dash', 'Express'),
('R3', 'Highway Freight', 'Standard'),
('R4', 'Rural Feeder', 'Standard');


INSERT INTO deliveries
(record_id, month, route_id, hub, promised_days, actual_days) VALUES
(1,  'Jan', 'R1', 'Ahmedabad', 2,  2),
(2,  'Jan', 'R2', 'Chennai',   3,  4),
(3,  'Jan', 'R3', 'Delhi',     5,  5),
(4,  'Jan', 'R4', 'Mumbai',    4, 10),
(5,  'Feb', 'R1', 'Chennai',   2,  5),
(6,  'Feb', 'R2', 'Delhi',     3,  3),
(7,  'Feb', 'R3', 'Mumbai',    5, 10),
(8,  'Feb', 'R4', 'Chennai',   6,  7),
(9,  'Mar', 'R1', 'Delhi',     2,  8),
(10, 'Mar', 'R2', 'Mumbai',    3,  5),
(11, 'Mar', 'R3', 'Chennai',   5,  5),
(12, 'Mar', 'R4', 'Mumbai',    6, 15);


