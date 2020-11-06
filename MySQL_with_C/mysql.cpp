


#define _CRT_SECURE_NO_WARNINGS
#include <mysql.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <iomanip>

using namespace std;
const int MENU_SIZE = 6;

// Employee structure
struct Employee {
	int employeeNumber;
	char lastName[50];
	char firstName[50];
	char email[100];
	char phone[50];
	char extension[10];
	char reportsTo[100];
	char jobTitle[50];
	char city[50];
};

// about menu
int menuSelector(int min, int max);
void displayMenu();
ostream& line(char ch, int num, const string mess, ostream& os = cout);
int menu();

// SQL
int findEmployee(MYSQL* conn, int employeeNumber, struct Employee* emp);
void displayEmployee(MYSQL* conn, struct Employee emp);
void displayAllEmployees(MYSQL* conn);

//Utils
void getString(char* str, const char* getStr, int size);

int menuSelector(int min, int max) { //user input check, if user input is not in btw 0 to 5 it will come with error
	int number;
	bool pass;

	do {
		pass = true;
		cin >> number;
		if (cin.fail()) {
			cin.clear();
			cin.ignore(2000, '\n');
			cout << "Enter Correct number between " << min << " and " << max << ": ";
			pass = false;
		}
		else if (number < min || number > max) {
			cout << "Enter Correct number between " << min << " and " << max << ": ";
			pass = false;
		}
	} while (!pass);
	return number;
}

void displayMenu() { // display menu
	string menuStr[] = { "Find Employee", "Employees Report", "Add Employee", "Update Employee", "Remove Employee", "Exit" };
	for (int i = 0; i < MENU_SIZE; ++i) {
		if (i < MENU_SIZE - 1)
			cout << i + 1 << ") " << menuStr[i] << endl;
		else
			cout << "0) " << menuStr[i] << endl;
	}
	cout << "Enter Number: ";
}



ostream& line(char ch, int num, string mess, ostream & os) { // sorting function all rows are right side employee information

	cout << right << setfill(ch) << setw(num + (int)mess.length()) << mess << setw(num + 1) << " " << setfill(' ');
	return os;
}



int menu() { // title
	line('*', 21, " HR MENU ") << endl;
	displayMenu();

	return menuSelector(0, 5);
}



int findEmployee(MYSQL * conn, int employeeNumber, struct Employee* emp) { //user selected by 1

	if (!conn) {					//connection check with database
		cout << "Connection Failed" << mysql_error(conn) << endl;
		return 0;
	}
	else {	    // if connection is ok do this condition.
		string empCode = "select employeeNumber from employees;";  // change c style string
		string empNum = to_string(employeeNumber); // change number to string

		const char* q1 = empCode.c_str(); 

		int exequery;
		exequery = mysql_query(conn, q1); // checking connection with query
		if (exequery)   // connection return 0 so if return by1 it will show error msg
			cout << "Error message: " << mysql_error(conn) << ": " << mysql_errno(conn) << endl;
		MYSQL_RES* res;   // store result set 
		res = mysql_store_result(conn);
		MYSQL_ROW row;  // get and store data by row 
		bool flag = true;
		while ((row = mysql_fetch_row(res)) && flag) {//check each row and bool
			if (row[0] == empNum) // check array[0] has empNum 
				flag = false;
		}
		if (!flag) { // check data valid
			// get all data from employee information from table (set query)
			string empInfo = "select * from employees e1 left join employees e2 on e1.reportsTo = e2.employeeNumber left join offices o on e1.officeCode = o.officeCode where e1.employeeNumber = ";
			empInfo += empNum;
			empInfo += ';';
			const char* q2 = empInfo.c_str();
			MYSQL_RES* res2;
			exequery = mysql_query(conn, q2);
			res2 = mysql_store_result(conn);
			row = mysql_fetch_row(res2);
			string lname(row[9] ? row[9] : " "), fname(row[10] ? row[10] : " "); // some employee has null information we put theire info by menual 
			fname = fname + " " + lname; // defined middle doesn't exist
			emp->employeeNumber = employeeNumber;
			getString(emp->lastName, row[1], 50);
			getString(emp->firstName, row[2], 50);
			getString(emp->email, row[4], 100);
			getString(emp->phone, row[18], 50);
			getString(emp->extension, row[3], 10);
			getString(emp->reportsTo, fname.c_str(), 100);
			getString(emp->jobTitle, row[7], 50);
			getString(emp->city, row[17], 50);
			return 1;
		}
		else {// if(flag) it will return msg
			cout << "Employee " << empNum << " does not exist in our database" << endl << endl;
			return 0;
		}
	}
}

void displayEmployee(MYSQL * conn, struct Employee emp) {

	int userInput;
	cout << "Enter Employee Number: ";
	userInput = menuSelector(0, 40000000); // user input number range

	if (findEmployee(conn, userInput, &emp)) {
		cout << endl;
		line('*', 15, " Employee Infomation ") << endl;
		cout << "employeeNumber = " << emp.employeeNumber << endl <<
			"lastName = " << emp.lastName << endl <<
			"firstName = " << emp.firstName << endl <<
			"email = " << emp.email << endl <<
			"phone = " << emp.phone << endl <<
			"extension = " << emp.extension << endl <<
			"reportsTo = " << emp.reportsTo << endl <<
			"jobTitle = " << emp.jobTitle << endl <<
			"city = " << emp.city << endl;
		cout << endl;
	}
}

void displayAllEmployees(MYSQL * conn) {
	string empInfo = "select * from employees e1 left join employees e2 on e1.reportsTo = e2.employeeNumber left join offices o on e1.officeCode = o.officeCode";
	const char* q = empInfo.c_str();

	int exequery;
	exequery = mysql_query(conn, q);

	if (exequery)
		cout << "Error message: " << mysql_error(conn) << ": " << mysql_errno(conn) << endl;
	else {
		MYSQL_RES* res;
		res = mysql_store_result(conn);
		MYSQL_ROW row;

		cout << "\n" << "E     Employee Name         Email                               Phone             Ext    Manager" << endl;
		line('-', 50, "") << endl;

		while ((row = mysql_fetch_row(res))) {
			// concat for empName
			string lname(row[1]), fname(row[2]);
			fname = fname + " " + lname;

			// concat for reportsTo
			string rlname(row[9] ? row[9] : " "), rfname(row[10] ? row[10] : " ");
			rfname = rfname + " " + rlname;

			cout << left << setw(6) << row[0] << setw(22) <<
				fname << setw(36) << row[4] << setw(18) <<
				row[18] << setw(7) << row[3] << setw(15) << rfname << endl;
		}
		cout << endl;
	}
}

void getString(char* str, const char* getStr, int size) {
	// when getStr is nullptr assign str to " "
	if (!getStr) {
		strcpy(str, " ");
	}

	else {
		strncpy(str, getStr, size - 1);
		str[size - 1] = '\0';
	}
}
int main(void) {

	MYSQL* conn;
	conn = mysql_init(0);

	conn = mysql_real_connect(conn, "mymysql.senecacollege.ca", "db_yalee2", "obc7CFbr%4", "db_yalee2", 3306, nullptr, 0);

	Employee emp = { 0 };

	int selection = 0;
	do {
		selection = menu();

		switch (selection) {
		case 0:
			break;
		case 1:
			displayEmployee(conn, emp);
			break;
		case 2:
			displayAllEmployees(conn);
			break;
		case 3:
			cout << "Not available" << endl;
			break;
		case 4:
			cout << "Not available" << endl;
			break;
		case 5:
			cout << "Not available" << endl;
			break;
		default:
			break;
		}
	} while (selection);
	return 0;
}