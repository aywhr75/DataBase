#include <mysql.h>
#include <stdlib.h>
#include <iostream>

using namespace std;

int main(void)
{

	MYSQL* conn;
	conn = mysql_init(0);

	conn = mysql_real_connect(conn, "mymysql.senecacollege.ca", "db_yalee2", "obc7CFbr%4", "db_yalee2", 3306, nullptr, 0);

	if (conn) {
		cout << "successful connection to database" << endl;
	}
	else {
		cout << "Connection Failed" << mysql_error(conn) << endl;
	}


	string query = "select * from offices;";
	const char* q = query.c_str();
	int exequery;
	exequery = mysql_query(conn, q);

	if (!exequery) {
		//query execution is successful
		cout << "the query executed successfully with no error." << endl;
	}
	else {
		//query execution is not successful
		cout << "Error message: " << mysql_error(conn) << ": " << mysql_errno(conn) << endl;
	}

	MYSQL_RES* res;
	res = mysql_store_result(conn);
	MYSQL_ROW row;


	if ((row = mysql_fetch_row(res)) == nullptr)
		cout << "The result is empty." << endl;
	else {
		do {
			printf("officecode: %s, city: %s\n", row[0], row[1]);
		} while (row = mysql_fetch_row(res));

	}
	mysql_close(conn);


	return 0;

}
/*sample out put
successful connection to database
the query executed successfully with no error.
officecode: 1, city: San Francisco
officecode: 2, city: Boston
officecode: 3, city: NYC
officecode: 4, city: Paris
officecode: 5, city: Tokyo
officecode: 6, city: Sydney
officecode: 7, city: London*/