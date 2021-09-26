create database TableRelations
use TableRelations

create table Passports(
PassportID int primary key identity(101,1),
PassportNumber varchar(8) not null
)

create table Persons(
PersonID int primary key identity,
FirstName nvarchar(50) not null,
Salary decimal(8,2) not null,
PassportID int foreign key references Passports(PassportID) unique not null
)


insert into Passports (PassportNumber)
Values
('N34FG21B')
,('K65LO4R7')
,('ZE657QP2')

insert into Persons(FirstName, Salary, PassportID)
Values
('Roberto', 43300.00, 102)
,('Tom', 56100.00, 103)
,('Yana', 60200.00, 101)



create table Manufacturers(
ManufacturerID int primary key identity,
Name varchar(20) not null,
EstablishedOn date not null
)

create table Models(
ModelID int primary key identity(101,1),
Name varchar (50) not null,
ManufacturerID int foreign key references Manufacturers
)



insert into Manufacturers (Name, EstablishedOn)
values
('BMW', '07/03/1916')
,('Tesla', '01/01/2003')
,('Lada', '01/05/1966')

insert into Models (Name, ManufacturerID)
values
('X1', 1)
,('i6', 1)
,('Model S', 2)
,('Model X', 2)
,('Model 3', 2)
,('Nova', 3)


create table Students(
StudentID int primary key identity,
Name varchar(50) not null
)

create table Exams(
ExamID int primary key identity (101,1),
Name varchar(50) not null
)


create table StudentsExams(
StudentID int,
ExamID int,
constraint PK_StudentsExams 
primary key (StudentID, ExamID),
constraint FK_StudentsExamc_Students 
foreign key (StudentID) references Students(StudentID),
constraint FK_StudentsExams_Exams 
foreign key (ExamID) references Exams(ExamID)
)

insert into Students(Name)
values
('Mila')
,('Toni')
,('Ron')

insert into Exams(Name)
values
('SpringMVC')
,('Neo4j')
,('Oracle 11g')

insert into StudentsExams(StudentID, ExamID)
values
(1, 101)
,(1, 102)
,(2, 101)
,(3, 102)
,(2, 102)
,(2, 103)


create database StoreDB

use storeDB

create table Cities(
CityID int primary key identity,
Name varchar(50) not null
)


create table Customers(
CustomerID int primary key identity,
Name varchar(50) not null,
Birthday date,
CityID int foreign key references Cities(CityID)
)


create table Orders(
OrderId int primary key identity,
CustomerID int foreign key references Customers(CustomerID)
)


create table ItemTypes(
ItemTypeID int primary key identity,
Name varchar(50) not null
)

create table Items(
ItemID int primary key identity,
Name varchar(50) not null,
ItemTypeID int foreign key references ItemTypes(ItemTypeID)
)

create table OrderItems(
OrderID int foreign key references Orders(OrderId),
ItemID int foreign key references Items(ItemID),
primary key (OrderID, ItemID) 
)

go

create table Majors(
MajorID int primary key identity,
Name varchar(50) not null
)

create table Students(
StudentID int primary key identity,
StudentNumber int not null,
StudentName varchar(50) not null,
MajorID int foreign key references Majors(MajorID) 
)


Create table Payments(
PaymentID int primary key identity,
PaymentDate date not null,
PaymentAmount decimal not null,
StudentID int foreign key references Students(StudentID)
)


create table Subjects(
SubjectID int primary key identity,
SubjectName varchar(50) not null
)


create table Agenda(
StudentID int foreign key references Students(StudentID),
SubjectID int foreign key references Subjects(SubjectID),
primary key (StudentID, SubjectID)
)

use geography

select MountainRange, PeakName, Elevation
from Peaks
join Mountains on Peaks.MountainId = Mountains.Id
where MountainRange = 'Rila'
order by Elevation desc

select * from Mountains