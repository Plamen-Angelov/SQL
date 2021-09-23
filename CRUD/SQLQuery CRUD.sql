use SoftUni


Select Name from Departments

Select FirstName, LastName, Salary
from Employees

Select FirstName, MiddleName, LastName
from Employees


Select FirstName+'.'+ LastName +'@softuni.bg' as [Full Email Address]
from Employees

select distinct Salary
from Employees


select * from Employees
where JobTitle = 'Sales Representative'

select FirstName, LastName, JobTitle
from Employees
where Salary >= 20000 and Salary <= 30000

select FirstName + ' ' + MiddleName + ' ' + LastName as [Full Name]
from Employees
where (Salary = 25000 or Salary= 14000 or Salary = 12500 or Salary = 23600)


select FirstName, LastName
from Employees
where ManagerID is null


select FirstName, LastName, Salary
from Employees
where Salary > 50000
order by Salary desc

select top (5) FirstName, LastName
from Employees
order by Salary desc

select FirstName, LastName
from Employees
where not DepartmentID = 4

select *
from employees
order by Salary desc,
FirstName,
LastName desc,
MiddleName

create view V_EmployeesSalaries
as(
select FirstName, LastName, Salary
from Employees)

create view V_EmployeeNameJobTitle
as(
select FirstName + ' ' + ISNULL(MiddleName,'') + ' ' + LastName as [Full Name], JobTitle
from Employees)


select distinct JobTitle
from Employees

select top 10 *
from Projects
where StartDate < GETDATE()
order by StartDate, Name


select top 7 [FirstName]
,[LastName]
,[HireDate]
from Employees
order by HireDate desc


update Employees
set Salary *= 1.12
where DepartmentID in (1,2,4,11)
select Salary
from Employees

select distinct DepartmentID, Name
from Departments

use Geography

select PeakName
from Peaks
order by PeakName asc


select top (30) [CountryName], [Population]
from Countries
where ([ContinentCode] = 'EU')
order by [Population] desc, [CountryName] asc


select [CountryName], [CountryCode],
case
	when CurrencyCode = 'EUR' then 'Euro'
	else 'Not Euro'
end as Currency
from Countries
order by CountryName


use Diablo

select Name
from Characters
order by Name