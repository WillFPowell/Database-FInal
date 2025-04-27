# Database-Final 
The instructions below enable users with database systems to easily access and utilize the database. (JG+WP)
1.	First, pull the file from the GIT Repository and download any program able to run a database system (we recommend downloading SQLDeveloper)
2.	Create a new connection as the user
3.	Run the schema script
4.	To insert data into the database, reference this example code:
INSERT INTO event_categories (name) VALUES ('Music');

5.	To update an existing host’s name, reference this example code:
UPDATE HOSTS
  	SET name = ‘Programming Club'
WHERE host_id =  10;
