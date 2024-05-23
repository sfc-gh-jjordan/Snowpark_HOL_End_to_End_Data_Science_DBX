Github Repo is: https://github.com/sfc-gh-jjordan/Snowpark_HOL_End_to_End_Data_Science_DBX

Step 1: Import the Image Files into DBFS
Note:  Only 1 user needs to perform this as the path can be shared in each user’s notebook
Upload the .png image files that reside in the assets folder in the github repo into DBFS and note the path to be updated in the workbook

Step 2: Import the requirements.txt to your Workspace
Note:  Only 1 user needs to perform this as the path can be shared in each user’s notebook
Import the requirements.txt file containing the packages to pip install
In the first cell modify the path to the correct location of the requirements.txt file

Step 3: Import the Hands On Lab Notebook to your Workspace
Import the Notebook named: End_to_End_Data_Science_using_Snowpark_Easy_Path_DBx.py into your workspace in Databricks.

Step 4: Import the authentication json file to your Workspace
Import the hol_auth.json file into your workspace in Databricks.
Modify the number you were assigned to for the user, role, warehouse and schema.

Step 5:  Modify the DBFS path to the image files used in the notebook
Do a find and replace on the path to the assets folder in DBFS where the .png image files reside.  
Find files/shared_uploads/joe.jordan@snowflake.com/assets/End_to_end_demo.pnand Replace with the correct path.

Step 6:  Run All in the notebook
If the connection to Snowflake is working then in the 4th cell after making the connection you will see the results printed with your WHx and SCHEMAx based on your assigned number.


