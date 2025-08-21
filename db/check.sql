-- Use the DB we created
USE rental_app;
GO

-- Quick sanity checks
SELECT COUNT(*) AS users_count FROM dbo.users;
SELECT COUNT(*) AS properties_count FROM dbo.properties;
SELECT COUNT(*) AS bookings_count FROM dbo.bookings;

-- Peek data
SELECT TOP 5 * FROM dbo.users ORDER BY user_id;
SELECT TOP 5 * FROM dbo.properties ORDER BY property_id;
SELECT TOP 5 * FROM dbo.bookings ORDER BY booking_id;
