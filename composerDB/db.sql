CREATE DATABASE WASHIFY;
USE WASHIFY;

CREATE TABLE users (
    id VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE bookings (
    booking_uuid VARCHAR(36) NOT NULL,
    booking_type VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    payment_status BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    PRIMARY KEY (booking_uuid)
);

CREATE TABLE payments (
    payment_uuid VARCHAR(36) NOT NULL,
    booking_uuid VARCHAR(36) NOT NULL,
    FOREIGN KEY (booking_uuid) REFERENCES bookings(booking_uuid),
    PRIMARY KEY (payment_uuid)
);
