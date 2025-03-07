-- Table to store days
CREATE TABLE Days (
    day_id SERIAL PRIMARY KEY,
    day_name VARCHAR(20) NOT NULL UNIQUE
);

-- Table to store lecturers
CREATE TABLE Lecturers (
    lecturer_id SERIAL PRIMARY KEY,
    lecturer_name VARCHAR(50) NOT NULL
);

-- Table to store course details
CREATE TABLE Courses (
    unit_code VARCHAR(10) PRIMARY KEY,
    unit_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    school VARCHAR(50)
);

-- Table to store timetable entries
CREATE TABLE Timetable (
    timetable_id SERIAL PRIMARY KEY,
    day_id INT REFERENCES Days(day_id),
    time_slot VARCHAR(20),
    room VARCHAR(50),
    unit_code VARCHAR(10) REFERENCES Courses(unit_code),
    lecturer_id INT REFERENCES Lecturers(lecturer_id),
    duration FLOAT,
    class_size INT,
    program VARCHAR(50),
    mode VARCHAR(10) CHECK (mode IN ('FT', 'PT', 'DL')),
    campus VARCHAR(50),
    trimester VARCHAR(20),
    stream VARCHAR(20),
    CONSTRAINT unique_lecturer_schedule UNIQUE (lecturer_id, day_id, time_slot),
    CONSTRAINT unique_stream_schedule UNIQUE (stream, day_id, time_slot),
    CONSTRAINT unique_room_schedule UNIQUE (room, day_id, time_slot)
);

-- Table to manage room allocation
CREATE TABLE RoomAllocation (
    room_id SERIAL PRIMARY KEY,
    room VARCHAR(50),
    is_occupied BOOLEAN DEFAULT FALSE,
    allocation_start TIMESTAMP,
    allocation_end TIMESTAMP
);

-- Function to update RoomAllocation based on Timetable entries
CREATE OR REPLACE FUNCTION update_room_allocation()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.room IS NOT NULL THEN
        INSERT INTO RoomAllocation (room, is_occupied, allocation_start, allocation_end)
        VALUES (NEW.room, TRUE, NOW(), NOW() + INTERVAL '1 hour' * NEW.duration);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to execute the function after an insert into Timetable
CREATE TRIGGER trg_update_room_allocation
AFTER INSERT ON Timetable
FOR EACH ROW
EXECUTE FUNCTION update_room_allocation();
