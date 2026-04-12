select *
from diabetes;

create table diabetes_staging
like diabetes;

insert diabetes_staging
select *
from diabetes;

select *
from diabetes_staging;

select *,
row_number() 
over(partition by Pregnancies,Glucose,BloodPressure,SkinThickness,Insulin,BMI,DiabetesPedigreeFunction,Age,Outcome) as row_num
from diabetes_staging;

with duplicate_cte as
(
select *,
row_number() 
over(partition by Pregnancies,Glucose,BloodPressure,SkinThickness,Insulin,BMI,DiabetesPedigreeFunction,Age,Outcome) as row_num
from diabetes_staging
)
select *
from duplicate_cte
where row_num > 1;

CREATE TABLE `diabetes_staging2` (
  `Pregnancies` int DEFAULT NULL,
  `Glucose` int DEFAULT NULL,
  `BloodPressure` int DEFAULT NULL,
  `SkinThickness` int DEFAULT NULL,
  `Insulin` int DEFAULT NULL,
  `BMI` double DEFAULT NULL,
  `DiabetesPedigreeFunction` double DEFAULT NULL,
  `Age` int DEFAULT NULL,
  `Outcome` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from diabetes_staging2;

insert into diabetes_staging2
select *,
row_number() 
over(partition by Pregnancies,Glucose,BloodPressure,SkinThickness,Insulin,BMI,DiabetesPedigreeFunction,Age,Outcome) as row_num
from diabetes_staging;


select *
from diabetes_staging2;

select 
Pregnancies,
trim(Pregnancies)
from diabetes_staging2;

update diabetes_staging2
set Pregnancies = trim(Pregnancies);

select Pregnancies
from diabetes_staging2;

select *
from diabetes_staging2;

select 
Glucose,
trim(Glucose)
from diabetes_staging2;

update diabetes_staging2
set Glucose = trim(Glucose);

select Glucose
from diabetes_staging2;

select *
from diabetes_staging2;

select 
BloodPressure,
trim(BloodPressure)
from diabetes_staging2;

update diabetes_staging2
set BloodPressure = trim(BloodPressure);

select BloodPressure
from diabetes_staging2;

select *
from diabetes_staging2;

select 
SkinThickness,
trim(SkinThickness)
from diabetes_staging2;

update diabetes_staging2
set SkinThickness = trim(SkinThickness);

select SkinThickness
from diabetes_staging2;

select *
from diabetes_staging2;

select 
Insulin,
trim(Insulin)
from diabetes_staging2;

update diabetes_staging2
set Insulin = trim(Insulin);

select Insulin
from diabetes_staging2;

select *
from diabetes_staging2;

select 
BMI,
trim(BMI)
from diabetes_staging2;

update diabetes_staging2
set BMI = trim(BMI);

select BMI
from diabetes_staging2;

select *
from diabetes_staging2;

select 
DiabetesPedigreeFunction,
trim(DiabetesPedigreeFunction)
from diabetes_staging2;

update diabetes_staging2
set DiabetesPedigreeFunction = trim(DiabetesPedigreeFunction);

select DiabetesPedigreeFunction
from diabetes_staging2;

select *
from diabetes_staging2;

select 
Age,
trim(Age)
from diabetes_staging2;

update diabetes_staging2
set Age = trim(Age);

select Age
from diabetes_staging2;

select *
from diabetes_staging2;

select 
Outcome,
trim(Outcome)
from diabetes_staging2;

update diabetes_staging2
set Outcome = trim(Outcome);

select Outcome
from diabetes_staging2;

select *
from diabetes_staging2;

select distinct
Pregnancies
from diabetes_staging2
order by 1;

select distinct
Glucose
from diabetes_staging2
order by 1;

select distinct
BloodPressure
from diabetes_staging2
order by 1;

select distinct
SkinThickness
from diabetes_staging2
order by 1;

select distinct
Insulin
from diabetes_staging2
order by 1;

select distinct
BMI
from diabetes_staging2
order by 1;

select distinct
DiabetesPedigreeFunction
from diabetes_staging2
order by 1;

select distinct
Age
from diabetes_staging2
order by 1;

select distinct
Outcome
from diabetes_staging2
order by 1;

select *
from diabetes_staging2;

select *
from diabetes_staging2
where Pregnancies is null;

select *
from diabetes_staging2
where Glucose is null;

select *
from diabetes_staging2
where BloodPressure is null;

select *
from diabetes_staging2
where SkinThickness is null;

select *
from diabetes_staging2
where Insulin is null;

select *
from diabetes_staging2
where BMI is null;

select *
from diabetes_staging2
where DiabetesPedigreeFunction is null;

select *
from diabetes_staging2
where Age is null;

select *
from diabetes_staging2
where Outcome is null;

alter table diabetes_staging2
drop column row_num;

select *
from diabetes_staging2;
