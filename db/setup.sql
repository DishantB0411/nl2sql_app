/* ---------- CREATE DATABASE ---------- */
IF DB_ID('rental_app') IS NULL
BEGIN
    CREATE DATABASE rental_app;
END
GO

USE rental_app;
GO

/* ---------- TABLES ---------- */

-- 1) users
IF OBJECT_ID('dbo.users','U') IS NOT NULL DROP TABLE dbo.users;
CREATE TABLE dbo.users (
    user_id     INT IDENTITY(1,1) PRIMARY KEY,
    first_name  NVARCHAR(100) NOT NULL,
    last_name   NVARCHAR(100) NOT NULL,
    email       NVARCHAR(150) NOT NULL UNIQUE,
    phone       NVARCHAR(20)  NULL,
    role        VARCHAR(20)   NOT NULL CHECK (role IN ('landlord','tenant','admin')),
    created_at  DATETIME2(0)  NOT NULL CONSTRAINT DF_users_created_at DEFAULT GETDATE()
);

-- 2) properties
IF OBJECT_ID('dbo.properties','U') IS NOT NULL DROP TABLE dbo.properties;
CREATE TABLE dbo.properties (
    property_id    INT IDENTITY(1,1) PRIMARY KEY,
    landlord_id    INT         NOT NULL,
    title          NVARCHAR(255) NOT NULL,
    description    NVARCHAR(MAX) NULL,
    property_type  VARCHAR(20) NOT NULL CHECK (property_type IN ('apartment','house','studio','villa')),
    address        NVARCHAR(255) NULL,
    city           NVARCHAR(100) NOT NULL,
    state          NVARCHAR(100) NULL,
    country        NVARCHAR(100) NOT NULL,
    bedrooms       INT          NULL,
    bathrooms      INT          NULL,
    rent_price     DECIMAL(12,2) NOT NULL,
    status         VARCHAR(20)  NOT NULL CHECK (status IN ('available','booked','inactive')),
    listed_at      DATETIME2(0) NOT NULL CONSTRAINT DF_properties_listed_at DEFAULT GETDATE(),
    CONSTRAINT FK_properties_landlord FOREIGN KEY (landlord_id) REFERENCES dbo.users(user_id)
);

-- 3) bookings
IF OBJECT_ID('dbo.bookings','U') IS NOT NULL DROP TABLE dbo.bookings;
CREATE TABLE dbo.bookings (
    booking_id  INT IDENTITY(1,1) PRIMARY KEY,
    property_id INT NOT NULL,
    tenant_id   INT NOT NULL,
    start_date  DATE NOT NULL,
    end_date    DATE NOT NULL,
    status      VARCHAR(20) NOT NULL CHECK (status IN ('pending','confirmed','cancelled','completed')),
    created_at  DATETIME2(0) NOT NULL CONSTRAINT DF_bookings_created_at DEFAULT GETDATE(),
    CONSTRAINT FK_bookings_property FOREIGN KEY (property_id) REFERENCES dbo.properties(property_id),
    CONSTRAINT FK_bookings_tenant   FOREIGN KEY (tenant_id)   REFERENCES dbo.users(user_id),
    CONSTRAINT CK_bookings_dates CHECK (start_date <= end_date)
);

-- 4) payments
IF OBJECT_ID('dbo.payments','U') IS NOT NULL DROP TABLE dbo.payments;
CREATE TABLE dbo.payments (
    payment_id   INT IDENTITY(1,1) PRIMARY KEY,
    booking_id   INT NOT NULL,
    tenant_id    INT NOT NULL,
    amount       DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    payment_date DATE NOT NULL,
    status       VARCHAR(20) NOT NULL CHECK (status IN ('initiated','successful','failed','refunded')),
    method       VARCHAR(20) NOT NULL CHECK (method IN ('credit_card','debit_card','bank_transfer','upi','cash')),
    CONSTRAINT FK_payments_booking FOREIGN KEY (booking_id) REFERENCES dbo.bookings(booking_id),
    CONSTRAINT FK_payments_tenant  FOREIGN KEY (tenant_id)  REFERENCES dbo.users(user_id)
);

-- 5) reviews
IF OBJECT_ID('dbo.reviews','U') IS NOT NULL DROP TABLE dbo.reviews;
CREATE TABLE dbo.reviews (
    review_id   INT IDENTITY(1,1) PRIMARY KEY,
    property_id INT NOT NULL,
    tenant_id   INT NOT NULL,
    rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment     NVARCHAR(MAX) NULL,
    created_at  DATETIME2(0) NOT NULL CONSTRAINT DF_reviews_created_at DEFAULT GETDATE(),
    CONSTRAINT FK_reviews_property FOREIGN KEY (property_id) REFERENCES dbo.properties(property_id),
    CONSTRAINT FK_reviews_tenant   FOREIGN KEY (tenant_id)   REFERENCES dbo.users(user_id)
);

-- 6) property_photos
IF OBJECT_ID('dbo.property_photos','U') IS NOT NULL DROP TABLE dbo.property_photos;
CREATE TABLE dbo.property_photos (
    photo_id     INT IDENTITY(1,1) PRIMARY KEY,
    property_id  INT NOT NULL,
    photo_url    NVARCHAR(1024) NOT NULL,
    uploaded_at  DATETIME2(0) NOT NULL CONSTRAINT DF_photos_uploaded_at DEFAULT GETDATE(),
    CONSTRAINT FK_photos_property FOREIGN KEY (property_id) REFERENCES dbo.properties(property_id)
);

-- 7) favorites (composite PK)
IF OBJECT_ID('dbo.favorites','U') IS NOT NULL DROP TABLE dbo.favorites;
CREATE TABLE dbo.favorites (
    tenant_id   INT NOT NULL,
    property_id INT NOT NULL,
    added_at    DATETIME2(0) NOT NULL CONSTRAINT DF_favorites_added_at DEFAULT GETDATE(),
    CONSTRAINT PK_favorites PRIMARY KEY (tenant_id, property_id),
    CONSTRAINT FK_favorites_tenant   FOREIGN KEY (tenant_id)   REFERENCES dbo.users(user_id),
    CONSTRAINT FK_favorites_property FOREIGN KEY (property_id) REFERENCES dbo.properties(property_id)
);

-- Helpful indexes
CREATE INDEX IX_properties_city_status ON dbo.properties(city, status);
CREATE INDEX IX_bookings_property_status ON dbo.bookings(property_id, status);
CREATE INDEX IX_payments_tenant ON dbo.payments(tenant_id);
GO

/* ---------- SEED DATA (SMALL BUT USEFUL) ---------- */

-- landlords
INSERT INTO dbo.users (first_name,last_name,email,phone,role) VALUES
('John','Smith','john.smith@landlord.com','111-111-1111','landlord'),
('Alice','Brown','alice.brown@landlord.com','222-222-2222','landlord'),
('Ravi','Kapoor','ravi.kapoor@landlord.com','333-333-3333','landlord');

-- tenants
INSERT INTO dbo.users (first_name,last_name,email,phone,role) VALUES
('Bob','Miller','bob.miller@tenant.com','444-444-4444','tenant'),
('Carol','Davis','carol.davis@tenant.com','555-555-5555','tenant'),
('Esha','Shah','esha.shah@tenant.com','666-666-6666','tenant'),
('Tom','Walker','tom.walker@tenant.com','777-777-7777','tenant'),
('Maya','Iyer','maya.iyer@tenant.com','888-888-8888','tenant');

-- properties
INSERT INTO dbo.properties (landlord_id,title,description,property_type,address,city,state,country,bedrooms,bathrooms,rent_price,status)
VALUES
(1,'Cozy 2BHK','2BHK near center','apartment','123 High St','London','England','UK',2,1,2000,'available'),
(2,'Luxury Villa','4 BHK with pool','villa','456 Palm Ave','Bradford','England','UK',4,3,4500,'booked'),
(1,'Studio Central','Compact studio','studio','78 King Rd','London','England','UK',0,1,1200,'available'),
(3,'Family House','3BHK suburb','house','12 Green Way','Bradford','England','UK',3,2,2200,'available'),
(2,'Riverside Apt','1BHK with view','apartment','9 Thames Rd','London','England','UK',1,1,1800,'booked'),
(3,'Modern Loft','Open-plan loft','apartment','5 Brick Ln','London','England','UK',1,1,2100,'inactive');

-- bookings
INSERT INTO dbo.bookings (property_id,tenant_id,start_date,end_date,status) VALUES
(1, 4, '2025-05-01','2025-05-31','completed'),
(2, 5, '2025-06-15','2025-07-14','confirmed'),
(5, 6, '2025-07-01','2025-07-31','completed'),
(4, 7, '2025-06-10','2025-06-25','cancelled'),
(1, 8, '2025-08-01','2025-08-31','pending');

-- payments
INSERT INTO dbo.payments (booking_id,tenant_id,amount,payment_date,status,method) VALUES
(1, 4, 2000, '2025-05-01','successful','upi'),
(2, 5, 4500, '2025-06-15','successful','credit_card'),
(3, 6, 1800, '2025-07-01','successful','debit_card'),
(4, 7, 0,    '2025-06-12','refunded','bank_transfer');

-- reviews
INSERT INTO dbo.reviews (property_id,tenant_id,rating,comment) VALUES
(1,4,4,'Nice and clean place'),
(2,5,5,'Amazing villa!'),
(5,6,3,'Good location, small kitchen');

-- favorites
INSERT INTO dbo.favorites (tenant_id,property_id) VALUES
(4,2),(5,1),(6,5);

-- photos
INSERT INTO dbo.property_photos (property_id,photo_url) VALUES
(1,'/photos/p1a.jpg'),(1,'/photos/p1b.jpg'),
(2,'/photos/p2a.jpg'),(5,'/photos/p5a.jpg');
GO
