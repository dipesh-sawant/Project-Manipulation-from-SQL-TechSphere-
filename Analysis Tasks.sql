-- 1. Employee Productivity Analysis:
-- - Identify employees with the highest total hours worked and least absenteeism.
 SELECT
	employeeid,
    employeename,
    sum(total_hours)+sum(overtime_hours) as hours_worked,
    sum(days_absent) as absenteesm
 FROM
	attendance_records
 GROUP BY
	employeeid,
    employeename
 ORDER BY
	hours_worked desc, 
    absenteesm asc;
------------------------------------------------------------------------------------------------------
-- 2. Departmental Training Impact:
-- - Analyze how training programs improve departmental performance.
SELECT 
	T.department_id,
AVG(CASE 
		WHEN E.performance_score = 'Excellent' THEN 5
        WHEN E.performance_score = 'Good' THEN 4
        WHEN E.performance_score = 'Average' THEN 3
		ELSE NULL
	END) AS AVG_PERFORMANCE,
AVG(feedback_score) AVG_FEEDBACK
FROM 
	training_programs T
JOIN 
	employee_details E
ON 
	T.employeeid = E.employeeid
GROUP BY 
	T.department_id;
------------------------------------------------------------------------------------------------------
-- 3. Project Budget Efficiency:
-- - Evaluate the efficiency of project budgets by calculating costs per hour worked.
Select 
	P.project_id,
    P.project_name,
    P.budget/sum(hours_worked) as cost_per_hour
from
	project_assignments P
group by 
	P.project_id, 
    P.project_name 
order by 
	cost_per_hour desc;
------------------------------------------------------------------------------------------------------
-- 4. Attendance Consistency:
-- - Measure attendance trends and identify departments with significant deviations.
-- select e.department_id,e.employeename, a.total_hours Total_hours,avg(a.total_hours) over(partition by e.department_id) as Avg_hours Total_hours-avg(a.total_hours) over(partition by e.department_id) as Deviation from employee_details e join attendance_records a on e.employeeid = a.employeeid
SELECT 
	E.DEPARTMENT_ID,
    E.EMPLOYEENAME,
    A.TOTAL_HOURS,
    AVG(A.TOTAL_HOURS) 
		OVER(PARTITION BY E.DEPARTMENT_ID) AS AVG_HOURS,
	TOTAL_HOURS-AVG(A.TOTAL_HOURS) 
		OVER(PARTITION BY E.DEPARTMENT_ID) AS DEVIATION
FROM 
	employee_details E
JOIN 
	attendance_records A
ON 
	E.employeeid = A.employeeid;
------------------------------------------------------------------------------------------------------
-- 5. Training and Project Success Correlation:
-- - Link training technologies with project milestones to assess the real-world impact of training.
select 
	T.technologies_covered,
    E.department_id,
    avg(T.feedback_score) as Avg_Feedback,
    sum(P.milestones_achieved) as Total_Milestones,
    sum(P.budget) as Total_Project_Budget
from 
	training_programs T 
join 
	employee_details E 
on 
	T.employeeid=E.employeeid
join 
	project_assignments P
on 
	P.employeeid = E.employeeid
group by 
	T.technologies_covered,E.department_id
order by 
	Total_Milestones desc;
------------------------------------------------------------------------------------------------------
-- 6. High-Impact Employees:
-- - Identify employees who significantly contribute to high-budget projects while maintaining excellent performance scores.
SELECT 
	e.employeeid,
    e.employeename,
    p.project_id,
    p.project_name,
    e.performance_score,
    p.budget
FROM employee_details AS e
JOIN project_assignments AS p
ON e.employeeid = p.employeeid
WHERE  e.performance_score = 'Excellent'
       AND p.budget > (
		SELECT Avg(budget)
        FROM project_assignments)
ORDER  BY p.budget DESC;
------------------------------------------------------------------------------------------------------
-- 7. Cross-Analysis of Training and Project Success
-- - Identify employees who have undergone training in specific technologies and contributed to high-performing projects using those technologies.
SELECT 
    e.employeeid,
    e.employeename,
    t.program_name AS training_program,
    t.technologies_covered,
    p.project_name,
    p.technologies_used,
    p.project_status
FROM 
    training_programs t
JOIN 
    employee_details e ON t.employeeid = e.employeeid
JOIN 
    project_assignments p ON e.employeeid = p.employeeid
WHERE 
    t.completion_status = 'Completed'
    AND p.project_status = 'Completed'
    AND FIND_IN_SET(t.technologies_covered, p.technologies_used) > 0
ORDER BY 
    e.employeename, p.project_name;
