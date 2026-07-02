-- ========================================================================
-- IRA Apprenticeship Compliance: Timecard Data Extraction
-- ========================================================================
-- Purpose: Pull worked hours for IRA-flagged employees across active 
--          construction projects for weekly ratio compliance reporting
-- Author:  Rogue Lafayette
-- ========================================================================

WITH current_job_assignment AS (
    SELECT
        employee_id,
        primary_job_code
    FROM workforce.person_details
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY employee_id 
        ORDER BY record_updated_dt DESC
    ) = 1
),

active_ira_projects AS (
    SELECT DISTINCT project_id
    FROM workforce.project_master
    WHERE project_status = 'Active'
      AND ira_covered_flag = TRUE
)

SELECT
    tc.timecard_id,
    tc.employee_id,
    tc.work_date,
    tc.project_id,
    tc.project_name,
    tc.cost_center_code,
    tc.cost_center_name,
    tc.craft_code,
    tc.craft_description,
    tc.hours_worked,
    tc.pay_code,
    tc.clock_in_dttm,
    tc.clock_out_dttm,
    cja.primary_job_code
    
FROM workforce.timecard_details tc

INNER JOIN active_ira_projects aip
    ON tc.project_id = aip.project_id
    
LEFT JOIN current_job_assignment cja
    ON tc.employee_id = cja.employee_id

WHERE tc.work_date BETWEEN '2024-01-01' AND '2024-06-30'
  
  -- Include only worked hours (regular, overtime, and shift differentials)
  AND tc.pay_code IN (
      'Regular', 'Overtime', 
      'ShiftDiff1', 'ShiftDiff2',
      'DoubleTime1', 'DoubleTime2'
  )
  
  -- Exclude non-productive cost centers (holidays, security)
  AND tc.cost_center_code NOT IN ('HOL-S', 'SECURITY')
  
  -- Only IRA-classified employees
  AND cja.primary_job_code LIKE '%/IRA'
  
  -- Completed shifts only (nulls indicate missed punches)
  AND tc.clock_out_dttm IS NOT NULL
  
  -- Exclude test/contractor employee IDs (internal convention: prefix 0)
  AND tc.employee_id LIKE '0%'

ORDER BY tc.work_date, tc.employee_id;
