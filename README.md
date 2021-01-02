# SQl-Server-Object-Scripter-using-Powershell

The project uses SQL Server SMO and Powershell to extract objects from SQl Server and store then in a local file repository.
 * Each object is stored in a seperate file
 * Objects are stored under a Folder of the same Database object type and have the same name as the Object in the databse.

### How to use 

#### Prerequisites

* The file `ScriptDBObjects.ps1` is the Powershell script . Open this script file preferably using a Powershell editor and replace the values for the 2 variables
  * $path - stores the location of the extracted 
  * $ServerName = Name of the SQL Server  from where we want to extract the objects
  * $SpecificDb = Name of the database for which we want objects to be scripted
  
 
 
* Execute the powershell script

* Once the powershell script is executed the objects should be created in the location specified by $path variable.

