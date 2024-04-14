## About The Project
The Hospital Database Management System (HDMS) is a comprehensive software solution designed to streamline and optimize the management of hospital operations. This system aims to centralize critical information, automate routine tasks, and provide healthcare providers with a user-friendly platform to efficiently manage patient records, staff information, medical inventory, appointments, billing, and reporting.

## Features
* **Patient Management:** Maintain detailed records of patients, including demographic information, medical history, treatment plans, and billing details. Enable easy scheduling of appointments and tracking of patient visits.
* **Staff Management:** Manage information about doctors. Track their schedules and responsibilities to ensure efficient staffing and treatment.
* **Treatment Scheduling:** Allow admin to assigns treatments.
* **Billing and Insurance:** Generate accurate billing statements for patients and insurance companies based on treatment provided and services rendered. Streamline the claims process to minimize errors and delays in reimbursement.
* **Reporting:** Generate insightful reports base on users selection.

## Installations
### Clone the repository:
```bash
git clone https://github.com/DangBaoTin/hospital-dbs-main.git
```

### Database Setup with MySQL Workbench

The Hospital Database Management System (HDMS) utilizes MySQL as the database management system. To simulate the database locally and interact with it using MySQL Workbench, follow these steps:

1. **Install MySQL Server:**
If you haven't already, download and install MySQL Server from the official MySQL website ([MySQL Downloads](https://dev.mysql.com/downloads/)).

2. **Create a New Database Instance:**
Using MySQL Workbench, create a new database instance where you will import the provided SQL schema.

3. **Import SQL Schema:**
   - Open MySQL Workbench and connect to your local MySQL server.
   - Select your newly created database instance.
   - Go to `File` > `Open SQL Script...` and select the `schema.sql` file provided in the `database` directory of this project.
   - Execute the SQL script to create the necessary tables and populate initial data.

4. **Update Database Configuration:**
In your Flask application file (e.g., `__init__.py`), configure the database URI:

```python
#app configuration
app.config['SECRET_KEY'] = 'abc'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:admin123@localhost/hospitaldbs'
##############################
```
Replace `'mysql+pymysql://root:admin123@localhost/hospitaldbs'` with your MySQL database URI. This URI specifies the database driver (`mysql+pymysql`), username (`root`), password (`admin123`), host (`localhost`), and database name (`hospitaldbs`).

### Using MySQL Workbench

MySQL Workbench provides a graphical user interface for managing MySQL databases. You can use it to view tables, execute queries, and perform various database management tasks. Refer to the [MySQL Workbench documentation](https://dev.mysql.com/doc/workbench/en/) for detailed instructions on how to use the tool effectively.

### Start the Application
After completing the database setup, start the application by running the file `main.py` in your project directory. The application will now connect to your local MySQL database and be ready for use.
```bash
python main.py
```
Once the application is running, you can access the web interface through your web browser. Use the provided login credentials to access different modules and functionalities based on your role within the hospital.

## Contributors
- Do Lam Ngoc Thuc 2153143
- Dang Bao Tin 2152313
- Tran Minh Triet 2153057
- Nguyen Thanh Tung 2152337
- Luong Le Long Vu 2153980

## Other
1. Fork the Project
2. Create your Feature Branch (`git checkout -b`)
3. Commit your Changes (`git commit -m 'Add something'`)
4. Push to the Branch (`git push origin`)
5. Open a Pull Request
Reports for the project:
* [Assigment part 1](https://drive.google.com/file/d/1nUGYE8axfoUVVmkqkpxrLnAh4Zigu4rf/view?usp=sharing)
* [Assigment part 2](https://drive.google.com/file/d/1v9-7xxb1KDfdZg6NAubUWlaVmUL8fcnG/view?usp=sharing)