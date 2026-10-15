 CREATE TABLE Roles (
   roleId       INT            PRIMARY KEY,
   roleName     VARCHAR(30)   NOT NULL, 
   description  VARCHAR(255)  NULL, 
   CONSTRAINT UQ_Role_roleName  UNIQUE (roleName), 
   CONSTRAINT CK_Role_roleName  CHECK (roleName IN ('Organiser', 'Participant')) 
); 
 

 CREATE TABLE Users ( 
   userId        INT PRIMARY KEY, 
   roleId        INT           NOT NULL,   -- Foreign Key 
   firstName     VARCHAR(80)   NOT NULL, 
   lastName      VARCHAR(80)   NOT NULL, 
   email         VARCHAR(120)  NOT NULL,                 
   password  VARCHAR(255)  NOT NULL,    
   CONSTRAINT UQ_User_email  UNIQUE (email), 
   CONSTRAINT FK_Users_Roles   FOREIGN KEY (roleId) REFERENCES Roles (roleId), 
   CONSTRAINT CK_Users_email  CHECK (email LIKE '%_@_%._%') 
); 

CREATE TABLE Event ( 
   eventId      INT            PRIMARY KEY, 
   userId       INT            NOT NULL,                       -- Foreign Key -> User (Organiser) 
   eventName    VARCHAR(120)   NOT NULL, 
   eventType    VARCHAR(10)    NOT NULL,                       -- Run / Walk / Cycle 
   eventDate    DATE           NOT NULL, 
   venue        VARCHAR(150)   NOT NULL, 
   status       VARCHAR(10)    NOT NULL 
       CONSTRAINT DF_Event_status DEFAULT ('Draft'), 
   description  VARCHAR(MAX)   NULL, 
   CONSTRAINT FK_Event_User       FOREIGN KEY (userId) REFERENCES Users (userId), 
   CONSTRAINT UQ_Event_NameDate   UNIQUE (eventName, eventDate), 
   CONSTRAINT CK_Event_eventType  CHECK (eventType IN ('Run', 'Walk', 'Cycle')), 
   CONSTRAINT CK_Event_status     CHECK (status IN ('Draft', 'Open', 'Closed', 'Completed', 'Cancelled')) 
);


CREATE TABLE WeatherObservation ( 
   weather_id        INT           PRIMARY KEY, 
   eventId           INT           NOT NULL,                   -- Foreign Key -> Event 
   observed_at       DATETIME2(0)  NOT NULL 
       CONSTRAINT DF_WeatherObservation_observed_at DEFAULT (SYSDATETIME()), 
   temperature_c     DECIMAL(4,1)  NULL, 
   conditions        VARCHAR(60)   NULL, 
   wind_speed_kmh    DECIMAL(5,1)  NULL, 
   precipitation_mm  DECIMAL(5,1)  NULL, 
   CONSTRAINT FK_WeatherObservation_Event   FOREIGN KEY (eventId) REFERENCES Event (eventId) ON DELETE CASCADE, 
   CONSTRAINT CK_WeatherObservation_wind    CHECK (wind_speed_kmh   IS NULL OR wind_speed_kmh   >= 0), 
   CONSTRAINT CK_WeatherObservation_precip  CHECK (precipitation_mm IS NULL OR precipitation_mm >= 0) 
);

CREATE TABLE Category ( 
   categoryId    INT           PRIMARY KEY, 
   eventId       INT           NOT NULL,                       -- Foreign Key -> Event 
   categoryName  VARCHAR(60)   NOT NULL, 
   entryFee      DECIMAL(8,2)  NOT NULL 
       CONSTRAINT DF_Category_entryFee DEFAULT (0.00), 
   startTime     TIME(0)       NOT NULL, 
   distance_km   DECIMAL(6,2)  NOT NULL, 
   CONSTRAINT FK_Category_Event        FOREIGN KEY (eventId) REFERENCES Event (eventId) ON DELETE CASCADE, 
   CONSTRAINT UQ_Category_EventName    UNIQUE (eventId, categoryName), 
   CONSTRAINT CK_Category_entryFee     CHECK (entryFee >= 0), 
   CONSTRAINT CK_Category_distance_km  CHECK (distance_km > 0) 
);

CREATE TABLE Route ( 
   routeId         INT            PRIMARY KEY, 
   categoryId      INT            NOT NULL,                    -- Foreign Key -> Category 
   routeName       VARCHAR(120)   NOT NULL, 
   startLocation   VARCHAR(150)   NOT NULL, 
   finishLocation  VARCHAR(150)   NOT NULL, 
   distance_Km     DECIMAL(6,2)   NOT NULL, 
   CONSTRAINT FK_Route_Category     FOREIGN KEY (categoryId) REFERENCES Category (categoryId) ON DELETE CASCADE, 
   CONSTRAINT UQ_Route_categoryId   UNIQUE (categoryId), 
   CONSTRAINT CK_Route_distance_Km  CHECK (distance_Km > 0) 
); 


CREATE TABLE Enrolment ( 
   enrolmentId    INT           PRIMARY KEY, 
   userId         INT           NOT NULL,                      -- Foreign Key -> User (Participant) 
   categoryId     INT           NOT NULL,                      -- Foreign Key -> Category 
   bibNumber      VARCHAR(10)   NULL,                         
   registeredAt   DATETIME2(0)  NOT NULL 
       CONSTRAINT DF_Enrolment_registeredAt DEFAULT (SYSDATETIME()), 
   paymentStatus  VARCHAR(10)   NOT NULL 
       CONSTRAINT DF_Enrolment_paymentStatus DEFAULT ('Pending'), 
   CONSTRAINT FK_Enrolment_Users          FOREIGN KEY (userId)     REFERENCES Users (userId), 
   CONSTRAINT FK_Enrolment_Category      FOREIGN KEY (categoryId) REFERENCES Category (categoryId), 
   CONSTRAINT UQ_Enrolment_UserCategory  UNIQUE (userId, categoryId),   -- one entry per participant per category 
   CONSTRAINT CK_Enrolment_paymentStatus CHECK (paymentStatus IN ('Pending', 'Paid', 'Refunded', 'Cancelled')) 
);


CREATE TABLE Result ( 
   resultId          INT           PRIMARY KEY, 
   enrolmentId       INT           NOT NULL,                   -- Foreign Key -> Enrolment (UNIQUE = at most one result) 
   userId            INT           NOT NULL,                   -- Foreign Key -> User (Organiser who captured it) 
   finishTime        TIME(2)       NULL, 
   overallPosition   INT           NULL, 
   categoryPosition  INT           NULL, 
   resultStatus      VARCHAR(10)   NOT NULL 
       CONSTRAINT DF_Result_resultStatus DEFAULT ('Finished'), 
   recordedAt        DATETIME2(0)  NOT NULL 
       CONSTRAINT DF_Result_recordedAt DEFAULT (SYSDATETIME()), 
   CONSTRAINT FK_Result_Enrolment     FOREIGN KEY (enrolmentId) REFERENCES Enrolment (enrolmentId) ON DELETE CASCADE, 
   CONSTRAINT FK_Result_User          FOREIGN KEY (userId)      REFERENCES Users (userId), 
   CONSTRAINT UQ_Result_enrolmentId   UNIQUE (enrolmentId), 
   CONSTRAINT CK_Result_resultStatus  CHECK (resultStatus IN ('Finished', 'DNF', 'DNS', 'DSQ')), 
   CONSTRAINT CK_Result_positions     CHECK ((overallPosition  IS NULL OR overallPosition  > 0) 
                                         AND (categoryPosition IS NULL OR categoryPosition > 0)), 
   CONSTRAINT CK_Result_finishTime    CHECK (resultStatus <> 'Finished' OR finishTime IS NOT NULL) 
); 

INSERT INTO Roles (roleId, roleName, description) VALUES 
   (1, 'Organiser',   'Creates, edits and deletes events; manages categories; captures results; views all enrolments'), 
   (2, 'Participant', 'Creates an account, browses and enters events, views own enrolments and tracks personal results'); 
 
-- ---------- Users: 2 Organisers (userId 1-2), 4 Participants (userId 3-6) ---------- 
INSERT INTO Users (userId, roleId, firstName, lastName, email, password) VALUES 
   (1, 1, 'Sipho',  'Ndlovu',        'sipho.ndlovu@comrades.co.za',      '$2a$11$Kx9fQ2pYh3V1aZ7l0rN4sUq1xJ2cE4bG8hK0mP3wT6yR9vL5nD1fS'), 
   (2, 1, 'Lerato', 'Mokoena',       'lerato.mokoena@cyclingtour.co.za', '$2a$11$M3nR7tW1yQ4uK8vB2xF6cH0jL5pZ9aS3dG7hN1kM4oP8rT2wV6yC'), 
   (3, 2, 'Thabo',  'Nkosi',         'thabo.nkosi@gmail.com',            '$2a$11$P1qW8eR4tY7uI0oP3aS6dF9gH2jK5lZ8xC1vB4nM7qW0eR3tY6uI'), 
   (4, 2, 'Aisha',  'Petersen',      'aisha.petersen@outlook.com',       '$2a$11$L5kJ2hG9fD6sA3pO0iU7yT4rE1wQ8zX5cV2bN9mK6jH3gF0dS7aP'), 
   (5, 2, 'Pieter', 'van der Merwe', 'pieter.vdm@yahoo.com',             '$2a$11$N8mL3kJ0hG7fD4sA1pO8iU5yT2rE9wQ6zX3cV0bN7mK4jH1gF8dS'), 
   (6, 2, 'Zanele', 'Dlamini',       'zanele.dlamini@webmail.co.za',     '$2a$11$Q2nM5lK8jH1gF4dS7aP0oI3uY6tR9eW2qZ5xC8vB1nM4kJ7hG0fD'); 

INSERT INTO Event (eventId, userId, eventName, eventType, eventDate, venue, status, description) VALUES 
   (1, 1, 'Comrades Marathon 2026',    'Run',   '2026-06-14', 'Durban City Hall, Durban, KwaZulu-Natal', 'Completed', 
       'The Ultimate Human Race. 2026 Up Run from Durban to Pietermaritzburg.'), 
   (2, 2, 'Cape Town Cycle Tour 2026', 'Cycle', '2026-03-08', 'Grand Parade, Cape Town, Western Cape',   'Completed',
       'The world''s largest timed cycle race around the Cape Peninsula.'), 
   (3, 1, 'Soweto Marathon 2026',      'Run',   '2026-11-01', 'FNB Stadium, Nasrec, Soweto, Gauteng',    'Open', 
       'The People''s Race past Vilakazi Street, the Hector Pieterson Memorial and FNB Stadium.'); 

INSERT INTO WeatherObservation (weather_id, eventId, observed_at, temperature_c, conditions, wind_speed_kmh, precipitation_mm) VALUES 
   (1, 1, '2026-06-14 05:00:00', 11.5, 'Clear',          8.0,  0.0), 
   (2, 1, '2026-06-14 12:00:00', 22.8, 'Partly cloudy', 14.5,  0.0), 
   (3, 2, '2026-03-08 06:00:00', 17.2, 'Windy',         38.0,  0.0), 
   (4, 2, '2026-03-08 11:00:00', 24.6, 'Sunny',         31.5,  0.0), 
   (5, 3, '2026-10-31 18:00:00', 19.0, 'Thunderstorms', 12.0, 14.2);   -- forecast for the upcoming event 

INSERT INTO Category (categoryId, eventId, categoryName, entryFee, startTime, distance_km) VALUES 
   (1, 1, 'Ultra Marathon',        1800.00, '05:30:00',  87.70), 
   (2, 2, '109 km Classic',         850.00, '06:15:00', 109.00), 
   (3, 2, '42 km Fun Ride',         450.00, '07:30:00',  42.00), 
   (4, 3, '42.2 km Marathon',       450.00, '06:00:00',  42.20), 
   (5, 3, '21.1 km Half Marathon',  300.00, '06:30:00',  21.10), 
   (6, 3, '10 km Run/Walk',         180.00, '07:00:00',  10.00); 

-- ---------- Routes (0..1 per category; the 10 km has no route yet) ---------- 
INSERT INTO Route (routeId, categoryId, routeName, startLocation, finishLocation, distance_Km) VALUES 
   (1, 1, 'Comrades Up Run',          'Durban City Hall',        'Scottsville Racecourse, Pietermaritzburg',  87.70), 
   (2, 2, 'Peninsula Classic',        'Grand Parade, Cape Town', 'Green Point, Cape Town',                   109.00), 
   (3, 3, 'Ou Kaapse Weg Fun Ride',   'Ou Kaapse Weg',           'Green Point, Cape Town',                    42.00), 
   (4, 4, 'Soweto Heritage Marathon', 'FNB Stadium',             'FNB Stadium',                               42.20), 
   (5, 5, 'Soweto Half',              'FNB Stadium',             'FNB Stadium',                               21.10);


INSERT INTO Enrolment (enrolmentId, userId, categoryId, bibNumber, registeredAt, paymentStatus) VALUES 
   (1, 3, 1, 'C14532', '2025-10-03 08:14:00', 'Paid'), 
   (2, 5, 1, 'C02087', '2025-10-01 06:45:00', 'Paid'), 
   (3, 4, 2, 'T30117', '2025-09-15 12:30:00', 'Paid'), 
   (4, 6, 3, 'T41208', '2025-11-20 18:05:00', 'Paid'), 
   (5, 3, 4, 'S01042', '2026-06-02 09:20:00', 'Paid'), 
   (6, 6, 5, 'S05511', '2026-06-10 14:00:00', 'Paid'), 
   (7, 4, 6, NULL,     '2026-09-15 19:45:00', 'Pending'); 


INSERT INTO Result (resultId, enrolmentId, userId, finishTime, overallPosition, categoryPosition, resultStatus, recordedAt) VALUES 
   (1, 1, 1, '09:42:17.45',  5210,  5210, 'Finished', '2026-06-14 18:30:00'), 
   (2, 2, 1, '11:23:05.02', 12874, 12874, 'Finished', '2026-06-14 18:30:00'), 
   (3, 3, 2, '04:05:33.20',  9876,  9876, 'Finished', '2026-03-08 15:00:00'), 
   (4, 4, 2, '02:12:40.88',  1203,  1203, 'Finished', '2026-03-08 15:00:00');

   






 

 
