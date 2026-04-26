CREATE TABLE IF NOT EXISTS request_log (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT now(),
  url TEXT NOT NULL,
  ip_address VARCHAR(50) NOT NULL,
  http_method VARCHAR(10) NOT NULL,
  controller VARCHAR(30) NOT NULL,
  action VARCHAR(30) NOT NULL
);

CREATE INDEX ON request_log (ip_address);
CREATE INDEX ON request_log (created_at);
CREATE INDEX ON request_log (controller);
