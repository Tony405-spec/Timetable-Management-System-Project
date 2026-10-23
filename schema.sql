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
    day_id INT NOT NULL REFERENCES Days(day_id),
    time_slot VARCHAR(20) NOT NULL,
    room VARCHAR(50) NOT NULL,
    unit_code VARCHAR(10) NOT NULL REFERENCES Courses(unit_code),
    lecturer_id INT NOT NULL REFERENCES Lecturers(lecturer_id),
    duration FLOAT NOT NULL CHECK (duration > 0),
    class_size INT CHECK (class_size IS NULL OR class_size >= 0),
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
    room VARCHAR(50) NOT NULL,
    is_occupied BOOLEAN DEFAULT FALSE,
    allocation_start TIMESTAMP NOT NULL,
    allocation_end TIMESTAMP NOT NULL,
    CONSTRAINT valid_allocation_window CHECK (allocation_end > allocation_start)
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
