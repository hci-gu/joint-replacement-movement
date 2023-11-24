CREATE TABLE steps (
    id SERIAL PRIMARY KEY,
    personal_id VARCHAR(255),
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

CREATE TABLE walking_steadiness (
    id SERIAL PRIMARY KEY,
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

CREATE TABLE walking_double_support_percentage (
    id SERIAL PRIMARY KEY,
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

CREATE TABLE walking_step_length (
    id SERIAL PRIMARY KEY,
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