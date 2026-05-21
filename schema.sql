-- ============================================================
-- PROJECT 1: Construction Project MIS Dashboard
-- Schema + Sample Data
-- Tool: PostgreSQL 14+
-- Domain: EPC / Infrastructure Construction
-- ============================================================

DROP TABLE IF EXISTS progress_updates CASCADE;
DROP TABLE IF EXISTS milestones CASCADE;
DROP TABLE IF EXISTS project_team CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- ------------------------------------------------------------
-- TABLE 1: clients
-- ------------------------------------------------------------
CREATE TABLE clients (
    client_id       SERIAL PRIMARY KEY,
    client_name     VARCHAR(150)    NOT NULL,
    client_type     VARCHAR(50),    -- Govt, PSU, Private
    contact_person  VARCHAR(100),
    city            VARCHAR(50)
);

INSERT INTO clients (client_name, client_type, contact_person, city) VALUES
('Ministry of Health and Family Welfare',   'Govt',     'Ramesh Verma',     'New Delhi'),
('NHAI - National Highways Authority',      'Govt',     'Suresh Kumar',     'New Delhi'),
('NMDC Limited',                            'PSU',      'Arjun Reddy',      'Hyderabad'),
('Adani Ports and SEZ Ltd',                 'Private',  'Kiran Shah',       'Ahmedabad'),
('Telangana State Road Dev Corp',           'Govt',     'Venkat Rao',       'Hyderabad'),
('Indian Railways - RVNL',                  'PSU',      'Dinesh Sharma',    'New Delhi');

-- ------------------------------------------------------------
-- TABLE 2: departments
-- ------------------------------------------------------------
CREATE TABLE departments (
    dept_id         SERIAL PRIMARY KEY,
    dept_name       VARCHAR(100),
    dept_head       VARCHAR(100)
);

INSERT INTO departments (dept_name, dept_head) VALUES
('Civil Structural',    'S.K. Nair'),
('Mechanical & MEP',    'R. Pillai'),
('Electrical',          'K. Menon'),
('Project Controls',    'A. Sharma'),
('QA/QC',               'P. Reddy'),
('Safety & HSE',        'M. Kumar');

-- ------------------------------------------------------------
-- TABLE 3: projects
-- ------------------------------------------------------------
CREATE TABLE projects (
    project_id          SERIAL PRIMARY KEY,
    project_name        VARCHAR(200)    NOT NULL,
    client_id           INT             REFERENCES clients(client_id),
    project_type        VARCHAR(50),    -- Hospital, Highway, Bridge, Industrial, Railway
    location            VARCHAR(100),
    contract_value_cr   NUMERIC(12,2),  -- in Crores INR
    planned_start       DATE,
    planned_end         DATE,
    actual_start        DATE,
    current_status      VARCHAR(30),    -- Active, Completed, On Hold, Delayed
    project_manager     VARCHAR(100)
);

INSERT INTO projects (project_name, client_id, project_type, location, contract_value_cr, planned_start, planned_end, actual_start, current_status, project_manager) VALUES
('AIIMS Guwahati — Main Hospital Block',        1, 'Hospital',    'Guwahati, Assam',          320.50, '2021-04-01', '2024-03-31', '2021-04-15', 'Active',    'G. Namballa'),
('NH-44 Four Laning — Package 3',               2, 'Highway',     'Nagpur–Gondia, MH',        580.00, '2021-06-01', '2024-05-31', '2021-06-10', 'Active',    'K. Iyer'),
('AIIMS Bibinagar — OPD Block',                 1, 'Hospital',    'Bibinagar, Telangana',      145.75, '2022-01-01', '2024-12-31', '2022-01-20', 'Active',    'R. Sharma'),
('NMDC Steel Plant — Utilities Block',          3, 'Industrial',  'Nagarnar, Chhattisgarh',   210.00, '2020-10-01', '2023-09-30', '2020-10-15', 'Completed', 'S. Pillai'),
('Adani Mundra Port — Warehouse Complex',       4, 'Industrial',  'Mundra, Gujarat',           98.50, '2022-06-01', '2024-06-30', '2022-06-15', 'Active',    'P. Menon'),
('ORR Elevated Corridor — Section 2',           5, 'Highway',     'Hyderabad, Telangana',     435.00, '2021-09-01', '2024-08-31', '2021-09-20', 'Delayed',   'V. Kumar'),
('RVNL — Railway Station Redevelopment',        6, 'Railway',     'Secunderabad, Telangana',  175.25, '2022-03-01', '2025-02-28', '2022-03-10', 'Active',    'A. Nair'),
('AIIMS Guwahati — Residential Block',          1, 'Hospital',    'Guwahati, Assam',          128.00, '2022-07-01', '2025-06-30', '2022-07-15', 'Active',    'G. Namballa');

-- ------------------------------------------------------------
-- TABLE 4: milestones
-- ------------------------------------------------------------
CREATE TABLE milestones (
    milestone_id        SERIAL PRIMARY KEY,
    project_id          INT             REFERENCES projects(project_id),
    milestone_name      VARCHAR(200),
    planned_date        DATE,
    actual_date         DATE,
    status              VARCHAR(20),    -- Completed, Pending, Delayed, Upcoming
    dept_id             INT             REFERENCES departments(dept_id)
);

INSERT INTO milestones (project_id, milestone_name, planned_date, actual_date, status, dept_id) VALUES
(1, 'Foundation Work Completion',           '2021-10-31', '2021-11-20', 'Completed', 1),
(1, 'Ground Floor Slab',                    '2022-03-31', '2022-04-15', 'Completed', 1),
(1, 'Structure Topping Out',                '2022-12-31', '2023-02-10', 'Completed', 1),
(1, 'MEP Rough-in Completion',              '2023-06-30', '2023-08-01', 'Completed', 2),
(1, 'Finishing Works — 50%',                '2023-12-31', NULL,         'Delayed',   1),
(1, 'Handover',                             '2024-03-31', NULL,         'Pending',   4),
(2, 'Earthwork Embankment — 100%',          '2022-03-31', '2022-04-20', 'Completed', 1),
(2, 'Bridge Substructure — All Spans',      '2022-09-30', '2022-10-15', 'Completed', 1),
(2, 'Bridge Superstructure — Launched',     '2023-03-31', '2023-05-20', 'Completed', 1),
(2, 'Pavement Laying — 70%',                '2023-09-30', NULL,         'Delayed',   1),
(2, 'Road Marking and Signage',             '2024-01-31', NULL,         'Pending',   1),
(3, 'Piling Work Completion',               '2022-06-30', '2022-07-10', 'Completed', 1),
(3, 'Ground Floor Structure',               '2022-12-31', '2023-01-15', 'Completed', 1),
(3, 'First Floor Slab',                     '2023-06-30', '2023-07-20', 'Completed', 1),
(3, 'External Facade Works',                '2024-03-31', NULL,         'Upcoming',  1),
(4, 'Civil Foundation',                     '2021-03-31', '2021-04-01', 'Completed', 1),
(4, 'Structural Steel Erection',            '2021-09-30', '2021-10-15', 'Completed', 1),
(4, 'Mechanical Installation',              '2022-06-30', '2022-07-01', 'Completed', 2),
(4, 'Commissioning and Handover',           '2023-09-30', '2023-10-05', 'Completed', 4),
(5, 'Foundation — All Warehouses',          '2022-12-31', '2023-01-10', 'Completed', 1),
(5, 'PEB Structure Erection',               '2023-06-30', '2023-07-15', 'Completed', 1),
(5, 'Roofing and Cladding',                 '2023-12-31', NULL,         'Delayed',   1);

-- ------------------------------------------------------------
-- TABLE 5: project_team
-- ------------------------------------------------------------
CREATE TABLE project_team (
    team_id         SERIAL PRIMARY KEY,
    project_id      INT             REFERENCES projects(project_id),
    employee_name   VARCHAR(100),
    designation     VARCHAR(100),
    dept_id         INT             REFERENCES departments(dept_id),
    joining_date    DATE,
    monthly_cost_k  NUMERIC(8,2)    -- monthly cost in thousands INR
);

INSERT INTO project_team (project_id, employee_name, designation, dept_id, joining_date, monthly_cost_k) VALUES
(1, 'G. Namballa',      'Project Manager',          4, '2021-04-15', 180),
(1, 'R. Krishnan',      'Sr. Civil Engineer',        1, '2021-04-15', 120),
(1, 'S. Mehta',         'MEP Engineer',              2, '2022-01-01',  95),
(1, 'P. Rao',           'QC Engineer',               5, '2021-06-01',  85),
(1, 'T. Nair',          'Safety Officer',            6, '2021-04-15',  70),
(2, 'K. Iyer',          'Project Manager',           4, '2021-06-10', 175),
(2, 'M. Reddy',         'Highway Engineer',          1, '2021-06-10', 115),
(2, 'A. Singh',         'Bridge Engineer',           1, '2021-06-10', 110),
(2, 'B. Kumar',         'Survey Engineer',           4, '2021-07-01',  80),
(3, 'R. Sharma',        'Project Manager',           4, '2022-01-20', 170),
(3, 'V. Pillai',        'Sr. Civil Engineer',        1, '2022-01-20', 115),
(3, 'D. Menon',         'Electrical Engineer',       3, '2022-06-01',  90),
(4, 'S. Pillai',        'Project Manager',           4, '2020-10-15', 165),
(4, 'N. Das',           'Mechanical Engineer',       2, '2020-10-15', 110),
(5, 'P. Menon',         'Project Manager',           4, '2022-06-15', 160),
(5, 'H. Shah',          'Civil Engineer',            1, '2022-06-15', 100),
(6, 'V. Kumar',         'Project Manager',           4, '2021-09-20', 172),
(6, 'L. Nair',          'Highway Engineer',          1, '2021-09-20', 112),
(7, 'A. Nair',          'Project Manager',           4, '2022-03-10', 168),
(8, 'G. Namballa',      'Project Manager',           4, '2022-07-15', 180);

-- ------------------------------------------------------------
-- TABLE 6: progress_updates
-- ------------------------------------------------------------
CREATE TABLE progress_updates (
    update_id           SERIAL PRIMARY KEY,
    project_id          INT             REFERENCES projects(project_id),
    update_date         DATE            NOT NULL,
    planned_progress    NUMERIC(5,2),   -- % as per baseline
    actual_progress     NUMERIC(5,2),   -- % actually achieved
    remarks             TEXT,
    updated_by          VARCHAR(100)
);

INSERT INTO progress_updates (project_id, update_date, planned_progress, actual_progress, remarks, updated_by) VALUES
(1, '2023-01-31', 55.00, 52.00, 'Slight delay in MEP rough-in',              'G. Namballa'),
(1, '2023-03-31', 62.00, 58.00, 'Labour shortage during Holi break',          'G. Namballa'),
(1, '2023-06-30', 72.00, 68.00, 'Monsoon impacted finishing works',           'G. Namballa'),
(1, '2023-09-30', 82.00, 75.00, 'Material supply delay — tiles and fixtures', 'G. Namballa'),
(1, '2023-12-31', 92.00, 82.00, 'Electrical testing pending clearance',       'G. Namballa'),
(2, '2023-01-31', 60.00, 58.00, 'Minor delay in bridge deck casting',         'K. Iyer'),
(2, '2023-03-31', 70.00, 65.00, 'Pavement layer rework due to quality issue', 'K. Iyer'),
(2, '2023-06-30', 78.00, 70.00, 'Monsoon — pavement work stopped',            'K. Iyer'),
(2, '2023-09-30', 88.00, 76.00, 'Right of way issue — 2km stretch',           'K. Iyer'),
(2, '2023-12-31', 95.00, 83.00, 'ROW resolved, accelerating pavement work',   'K. Iyer'),
(3, '2023-01-31', 40.00, 42.00, 'Ahead of schedule — good monsoon planning',  'R. Sharma'),
(3, '2023-06-30', 60.00, 62.00, 'Structure work ahead of plan',               'R. Sharma'),
(3, '2023-12-31', 75.00, 72.00, 'Facade subcontractor mobilisation delayed',  'R. Sharma'),
(5, '2023-06-30', 50.00, 52.00, 'PEB erection faster than planned',           'P. Menon'),
(5, '2023-12-31', 80.00, 74.00, 'Roofing contractor delayed mobilisation',    'P. Menon'),
(6, '2023-06-30', 65.00, 55.00, 'ROW dispute — 3km stuck',                    'V. Kumar'),
(6, '2023-12-31', 85.00, 68.00, 'Utility shifting pending — GHMC delay',      'V. Kumar'),
(7, '2023-06-30', 35.00, 38.00, 'Demo and enabling works faster than plan',   'A. Nair'),
(7, '2023-12-31', 55.00, 52.00, 'Material approval delay from Railways',      'A. Nair'),
(8, '2023-12-31', 45.00, 48.00, 'Piling and foundation ahead of schedule',    'G. Namballa');
