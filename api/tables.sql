CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    personal_id VARCHAR(255),
    created_at TIMESTAMP,
    event_date TIMESTAMP    
)

CREATE TABLE steps (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    value INTEGER,
    data_type VARCHAR(255),
    unit VARCHAR(255),
    date_from TIMESTAMP,
    date_to TIMESTAMP,
    platform_type VARCHAR(255),
    device_id VARCHAR(255),
    source_id VARCHAR(255),
    source_name VARCHAR(255)
);

CREATE TABLE walking_speed (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    personal_id VARCHAR(255),
    value NUMERIC,
    data_type VARCHAR(255),
    unit VARCHAR(255),
    date_from TIMESTAMP,
    date_to TIMESTAMP,
    platform_type VARCHAR(255),
    device_id VARCHAR(255),
    source_id VARCHAR(255),
    source_name VARCHAR(255)
);

CREATE TABLE walking_asymmetry_percentage (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    value NUMERIC,
    data_type VARCHAR(255),
    unit VARCHAR(255),
    date_from TIMESTAMP,
    date_to TIMESTAMP,
    platform_type VARCHAR(255),
    device_id VARCHAR(255),
    source_id VARCHAR(255),
    source_name VARCHAR(255)
);

CREATE TABLE walking_steadiness (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    value NUMERIC,
    data_type VARCHAR(255),
    unit VARCHAR(255),
    date_from TIMESTAMP,
    date_to TIMESTAMP,
    platform_type VARCHAR(255),
    device_id VARCHAR(255),
    source_id VARCHAR(255),
    source_name VARCHAR(255)
);

CREATE TABLE walking_double_support_percentage (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    value NUMERIC,
    data_type VARCHAR(255),
    unit VARCHAR(255),
    date_from TIMESTAMP,
    date_to TIMESTAMP,
    platform_type VARCHAR(255),
    device_id VARCHAR(255),
    source_id VARCHAR(255),
    source_name VARCHAR(255)
);

CREATE TABLE walking_step_length (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    value NUMERIC,
    data_type VARCHAR(255),
    unit VARCHAR(255),
    date_from TIMESTAMP,
    date_to TIMESTAMP,
    platform_type VARCHAR(255),
    device_id VARCHAR(255),
    source_id VARCHAR(255),
    source_name VARCHAR(255)
);

CREATE TABLE questionnaires (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    created_at TIMESTAMP,
    name VARCHAR(255),
    answers JSON
);

ALTER TABLE steps ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE walking_speed ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE walking_asymmetry_percentage ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE walking_steadiness ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE walking_double_support_percentage ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE walking_step_length ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE questionnaires ADD FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;