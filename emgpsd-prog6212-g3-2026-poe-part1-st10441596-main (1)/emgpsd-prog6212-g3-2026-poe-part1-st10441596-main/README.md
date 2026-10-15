
<img width="2048" height="768" alt="image" src="https://github.com/user-attachments/assets/8c1577b7-5270-43aa-8c0c-9a6114032a9f" />

# RaceDay – Event Management System
---

## Project overview

RaceDay is a full-stack, web-based event management system for the South African road running, walking and cycling community. It replaces paper-based registration and spreadsheets with a single platform where **Event Organisers** create and manage events, categories, routes and results, and **Participants** browse events, enrol, track their performance history and prepare for race day with route and weather information.

The project is built progressively across three parts. Part 1 covers the planning and database design.

## Part 1 deliverables

| Section | Deliverable | Location |
|---|---|---|
| A | Entity Relationship Diagram (ERD) | `docs/ST10441596 - Programming 2B.pdf` |
| B | REST API Endpoint Plan | `docs/ST10441596 - Programming 2B.pdf` |
| C | SQL Database Script (SQL Server) | `docs/SQLQuery1.sql` |
| – | CI/CD validation workflow | `.github/workflows/validate.yml` |

## Repository structure

```
.
├── .github/
│   └── workflows/
│       └── validate.yml          # GitHub Actions – validates repo structure
├── docs/
│   ├── Section-A-ERD.pdf         # Entity Relationship Diagram
│   ├── Section-B-ST10441596 - Programming 2B.pdf
│   ├── Section-C-SQLQuery1.sql
│   └── ci-green-build.png        # Screenshot of successful workflow run
└── README.md
```

## Database design (Section C)

The script targets **Microsoft SQL Server** and was written and tested in SQL Server Management Studio (SSMS). It creates eight tables with primary keys, foreign keys, UNIQUE, CHECK and DEFAULT constraints, then inserts sample data.

| Table | Purpose |
|---|---|
| `Roles` | System roles – Organiser and Participant |
| `Users` | All accounts; each user has exactly one role |
| `Event` | Events created by an Organiser (Run / Walk / Cycle) |
| `Category` | Distance/entry categories within an event |
| `Route` | Start, finish and distance for a category (one route per category) |
| `WeatherObservation` | Weather readings linked to an event |
| `Enrolment` | A Participant's entry into a category (one per participant per category) |
| `Result` | Finish time and positions for an enrolment (at most one result per enrolment) |

### Running the script
1. Open SSMS and connect to a SQL Server instance.
2. Open `docs/SQLQuery1.sql`.
3. Execute (F5). The script creates the database objects and seed data.
4. Verify with `SELECT * FROM Roles;`, `SELECT * FROM Users;`, etc.

## API endpoint plan (Section B)

The API is organised into resource groups, all prefixed with `/api/`:

- **Authentication** – register, login, logout, current user
- **User Profile** – view and update own profile
- **Events** – CRUD, Organiser-owned
- **Categories** – CRUD nested under events
- **Routes** – one route per category (GET / PUT / DELETE)
- **Weather** – observations linked to an event
- **Enrolments** – Participants enter categories
- **Results** – Organisers capture results per enrolment

Full method, route, description, role, request body and expected response for every endpoint are in `docs/ST10441596 - Programming 2B.pdf`.

## CI/CD

Every push to `main` triggers a GitHub Actions workflow (`.github/workflows/validate.yml`) that checks:

- the `/docs` folder exists;
- the required planning documents and `SQLQuery1.sql` are present;
- the SQL script contains the expected `CREATE TABLE` statements.

### Successful build

My jobs have failed because of the Actions limit that occurred. 

## Tools used

- SQL Server Management Studio (SSMS) – database script
- Lucidchart – ERD
- Microsoft Word – planning documents
- GitHub & GitHub Actions – version control and CI

## YouTube video
https://youtu.be/DBIockaHMjU

## References

See the *Referencing* section in `docs/ST10441596 - Programming 2B.pdf` for the full reference list.
