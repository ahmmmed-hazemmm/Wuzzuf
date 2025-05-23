-- Create JobPortal Database
USE master;
GO

-- Drop database if it exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'JobPortal')
BEGIN
    ALTER DATABASE JobPortal SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE JobPortal;
END
GO

-- Create new database
CREATE DATABASE JobPortal;
GO

USE JobPortal;
GO

-- Create Admin Table
CREATE TABLE Admins (
    AdminId INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL,
    Password NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Create JobSeekers Table
CREATE TABLE JobSeekers (
    SeekerId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200),
    Resume NVARCHAR(MAX),
    ProfilePicture NVARCHAR(MAX),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

-- Create Employers Table
CREATE TABLE Employers (
    EmployerId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Address NVARCHAR(200),
    CompanyDescription NVARCHAR(MAX),
    CompanyLogo NVARCHAR(MAX),
    Website NVARCHAR(100),
    CreatedDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);
GO

-- Create Skills Table
CREATE TABLE Skills (
    SkillId INT IDENTITY(1,1) PRIMARY KEY,
    SkillName NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Create JobCategories Table
CREATE TABLE JobCategories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Create Jobs Table
CREATE TABLE Jobs (
    JobId INT IDENTITY(1,1) PRIMARY KEY,
    EmployerId INT FOREIGN KEY REFERENCES Employers(EmployerId),
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    CategoryId INT FOREIGN KEY REFERENCES JobCategories(CategoryId),
    Location NVARCHAR(100),
    Salary DECIMAL(18,2),
    JobType NVARCHAR(50), -- Full-time, Part-time, Contract, etc.
    PostedDate DATETIME DEFAULT GETDATE(),
    Deadline DATETIME,
    IsActive BIT DEFAULT 1
);
GO

-- Create JobSkills Table (Many-to-Many relationship between Jobs and Skills)
CREATE TABLE JobSkills (
    JobSkillId INT IDENTITY(1,1) PRIMARY KEY,
    JobId INT FOREIGN KEY REFERENCES Jobs(JobId) ON DELETE CASCADE,
    SkillId INT FOREIGN KEY REFERENCES Skills(SkillId) ON DELETE CASCADE
);
GO

-- Create SeekerSkills Table (Many-to-Many relationship between JobSeekers and Skills)
CREATE TABLE SeekerSkills (
    SeekerSkillId INT IDENTITY(1,1) PRIMARY KEY,
    SeekerId INT FOREIGN KEY REFERENCES JobSeekers(SeekerId) ON DELETE CASCADE,
    SkillId INT FOREIGN KEY REFERENCES Skills(SkillId) ON DELETE CASCADE
);
GO

-- Create JobApplications Table
CREATE TABLE JobApplications (
    ApplicationId INT IDENTITY(1,1) PRIMARY KEY,
    JobId INT FOREIGN KEY REFERENCES Jobs(JobId) ON DELETE CASCADE,
    SeekerId INT FOREIGN KEY REFERENCES JobSeekers(SeekerId) ON DELETE CASCADE,
    AppliedDate DATETIME DEFAULT GETDATE(),
    CoverLetter NVARCHAR(MAX),
    Status NVARCHAR(50) DEFAULT 'Pending', -- Pending, Reviewed, Interviewed, Rejected, Accepted
    ResumeFile NVARCHAR(MAX)
);
GO

-- Create Education Table for JobSeekers
CREATE TABLE Education (
    EducationId INT IDENTITY(1,1) PRIMARY KEY,
    SeekerId INT FOREIGN KEY REFERENCES JobSeekers(SeekerId) ON DELETE CASCADE,
    Degree NVARCHAR(100) NOT NULL,
    Institution NVARCHAR(100) NOT NULL,
    FieldOfStudy NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Description NVARCHAR(MAX)
);
GO

-- Create Experience Table for JobSeekers
CREATE TABLE Experience (
    ExperienceId INT IDENTITY(1,1) PRIMARY KEY,
    SeekerId INT FOREIGN KEY REFERENCES JobSeekers(SeekerId) ON DELETE CASCADE,
    JobTitle NVARCHAR(100) NOT NULL,
    Company NVARCHAR(100) NOT NULL,
    Location NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    Description NVARCHAR(MAX),
    IsCurrentJob BIT DEFAULT 0
);
GO

-- Create Stored Procedures

-- Admin Login
CREATE PROCEDURE SP_AdminLogin
    @Username NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    SELECT * FROM Admins WHERE Username = @Username;
END
GO

-- JobSeeker Login
CREATE PROCEDURE SP_JobSeekerLogin
    @Email NVARCHAR(100)
AS
BEGIN
    SELECT * FROM JobSeekers WHERE Email = @Email;
END
GO

-- Employer Login
CREATE PROCEDURE SP_EmployerLogin
    @Email NVARCHAR(100)
AS
BEGIN
    SELECT * FROM Employers WHERE Email = @Email;
END
GO

-- Create JobSeeker
CREATE PROCEDURE SP_CreateJobSeeker
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Password NVARCHAR(100),
    @Phone NVARCHAR(20) = NULL,
    @Address NVARCHAR(200) = NULL
AS
BEGIN
    INSERT INTO JobSeekers (FirstName, LastName, Email, Password, Phone, Address)
    VALUES (@FirstName, @LastName, @Email, @Password, @Phone, @Address);
    
    SELECT SCOPE_IDENTITY() AS SeekerId;
END
GO

-- Create Employer
CREATE PROCEDURE SP_CreateEmployer
    @CompanyName NVARCHAR(100),
    @Email NVARCHAR(100),
    @Password NVARCHAR(100),
    @Phone NVARCHAR(20) = NULL,
    @Address NVARCHAR(200) = NULL,
    @CompanyDescription NVARCHAR(MAX) = NULL,
    @Website NVARCHAR(100) = NULL
AS
BEGIN
    INSERT INTO Employers (CompanyName, Email, Password, Phone, Address, CompanyDescription, Website)
    VALUES (@CompanyName, @Email, @Password, @Phone, @Address, @CompanyDescription, @Website);
    
    SELECT SCOPE_IDENTITY() AS EmployerId;
END
GO

-- Insert default admin
INSERT INTO Admins (Username, Password, Email)
VALUES ('admin', '$2a$11$jPL3MQbvCodTRrTQTpTR6.mxm5Xz9q5Ygb1VY9JUJUlX9QmKI5VVa', 'admin@jobportal.com'); -- Password: Admin@123

-- Insert sample job categories
INSERT INTO JobCategories (CategoryName) VALUES 
('Information Technology'),
('Healthcare'),
('Finance'),
('Education'),
('Marketing'),
('Engineering'),
('Sales'),
('Customer Service'),
('Human Resources'),
('Administrative');

-- Insert sample skills
INSERT INTO Skills (SkillName) VALUES 
('JavaScript'),
('Python'),
('Java'),
('SQL'),
('HTML/CSS'),
('React'),
('Angular'),
('Node.js'),
('AWS'),
('Docker'),
('Kubernetes'),
('Machine Learning'),
('Data Analysis'),
('Project Management'),
('Communication'),
('Leadership'),
('Problem Solving'),
('Teamwork'),
('Time Management'),
('Creativity');

PRINT 'JobPortal database and tables created successfully!';
GO