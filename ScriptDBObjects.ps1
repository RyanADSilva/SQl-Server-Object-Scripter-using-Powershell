#DB Scripter -- Ryan D'Silva
#Script all DB Objects per artifact using SMO and Powershell

cls
$path = “” #provide destination path here 
$ServerName = “” # provide SQL Server Name here 
[System.Reflection.Assembly]::LoadWithPartialName(‘Microsoft.SqlServer.SMO’)
$serverInstance = New-Object (‘Microsoft.SqlServer.Management.Smo.Server’) $ServerName

$IncludeTypes = @(“Tables”,”StoredProcedures”,”Views”,”UserDefinedFunctions”,"Schemas","Synonyms","PartitionScheme","PartitionFunction" ,"Default")
$ExcludeSchemas = @(“sys”,”Information_Schema”)

$SpecificDb = “” # Provide name of the database to be scripted

$so = new-object (‘Microsoft.SqlServer.Management.Smo.ScriptingOptions’)
$so.IncludeIfNotExists = 0
$so.SchemaQualify = 1
$so.AllowSystemObjects = 0
$so.ScriptDrops = 0         #Script Drop Objects
$so.NoFileGroup = 1         #Do not need this for TSA as all tables are residing on the primary Filegroup
#$so.DriAllConstraints = 1
#$so.DriAll = 1
#$so.Default = 1
#scripter.Options.DriAllConstraints = true;
$so.ScriptBatchTerminator = 1
$so.NoCommandTerminator = 0

$so.AnsiFile=0
$so.AnsiPadding=0
$so.ToFileOnly = 1



$dbs=$serverInstance.Databases
foreach ($db in $dbs)
{

   $dbname = “$db”.replace(“[“,””).replace(“]”,””) 
   $dbpath = “$path”+”$dbname” + “\”

   if ( $dbname -eq $SpecificDb )
   {	
   

    if ( !(Test-Path $dbpath))

           {$null=new-item -type directory -name “$dbname”-path “$path”}

      #Script the database object  
      
      $dbpathDatabase =  $dbpath + "Database"  + "\" 
      $dbpathDatabaseFile = $dbpathDatabase + “$dbname” + “.sql” 
      #$db.NoCollation = $false
      if ( !(Test-Path $dbpathDatabase))
            {$null=new-item -type directory -name “Database”-path “$dbpath”}
      
        #Delete the folder contents if they exists
       $objpathIndexes = “$dbpath” + “Indexes” + “\”
       $objpathKeys = “$dbpath” + “Keys” + “\”
       $objpathTrigger = “$dbpath” + “Triggers” + “\”
       $objpathChecks = “$dbpath” + “Checks” + “\”
       $objpathForeignKeys = “$dbpath” + “Foreignkeys” + “\”
       $objpathDefaults = “$dbpath” + “DefaultConstraints” + “\”


        #Clear contents of all files in the path as the files will be recreated
        if ( (Test-Path $dbpath)) { 
            Get-ChildItem -Path $dbpath -Include *.sql -File -Recurse | foreach { Clear-Content  $_}  
        }

      $so.ScriptDrops = 1
      ##$so.IncludeHearders = 1  
      $db.Script() | Out-File "$dbpathDatabaseFile"    
      ##$so.IncludeHearders = 0
      $so.ScriptDrops = 0


       #Below code commented to delete the old file  
       #Write-Host $objpathIndexes
       #Write-Host $objpathKeys 
       #if ( (Test-Path $objpathIndexes)) {   
       # Get-ChildItem -Path $objpathIndexes -Include *.sql -File -Recurse | foreach { $_.Delete()}
       # }



       #Write-Host "Deleted Folder contents"


#


       foreach ($Type in $IncludeTypes)

       {

              $objpath = “$dbpath” + “$Type” + “\”

         if ( !(Test-Path $objpath))

           {$null=new-item -type directory -name “$Type”-path “$dbpath”}

              foreach ($objs in $db.$Type)

              {


                     If ($ExcludeSchemas -notcontains $objs.Schema ) 

                      {

                           $ObjName = “$objs”.replace(“[“,””).replace(“]”,””)                  

                           $OutFile = “$objpath” + “$ObjName” + “.sql”

                            $Find = "SET QUOTED_IDENTIFIER ON"
                            $Replace = "SET QUOTED_IDENTIFIER ON " +"`r`n" + "GO"
                            #$objs.Script($so)+”GO” | out-File $OutFile #-Append
                            #$object.replace $Find $Replace | 
                            $sps =  $objs.Script($so)+”GO”
                            $sps = $sps -replace $Find , $Replace
                            $sps  | out-File $OutFile

                           
                           if ( $Type -eq "tables" )
                           {
                           
                                $objpathTrigger = “$dbpath” + “Triggers” + “\”

                                 if ( !(Test-Path $objpathTrigger))

                                        {$null=new-item -type directory -name “Triggers”-path “$dbpath”}                           
                           
                              foreach ($objTrigger in $objs.Triggers)
                              {
                                    $ObjNametrigger = “$objTrigger”.replace(“[“,””).replace(“]”,””)                  

                                    $OutFiletrigger = “$objpathTrigger” + “$ObjName” + “.sql”

                                    $objTrigger.Script($so)+”GO” | out-File $OutFiletrigger -Append                                
                              }
                              
                              
                                $objpathIndexes = “$dbpath” + “Indexes” + “\”
                                $objpathKeys = “$dbpath” + “Keys” + “\”

                                 if ( !(Test-Path $objpathIndexes))

                                        {$null=new-item -type directory -name “Indexes”-path “$dbpath”}  

                                        
                                 if ( !(Test-Path $objpathKeys))

                                        {$null=new-item -type directory -name “Keys”-path “$dbpath”}                                                            
                           
                              #$OverwiteIndexFile = 1  
                              foreach ($objIndex in $objs.Indexes)
                              {
                                    $ObjNameIndex = “$objIndex”.replace(“[“,””).replace(“]”,””)                  
                                    
                                    if ( $objIndex.IndexKeyType -eq "DriPrimaryKey" ) 
                                    {
                                       $OutFileIndex = “$objpathKeys” + “$ObjName” + “.sql” 
                                    }
                                    else
                                    {
                                    $OutFileIndex = “$objpathIndexes” + “$ObjName” + “.sql”
                                    }
                                    #Write-Host $OutFileIndex 
                        
                                    $objIndex.Script($so)+”GO” | out-File $OutFileIndex -Append                                
                                        
                              }  
                              

                                $objpathChecks = “$dbpath” + “Checks” + “\”

                                 if ( !(Test-Path $objpathChecks))

                                        {$null=new-item -type directory -name “Checks”-path “$dbpath”}                           
                           
                              foreach ($objCheck in $objs.Checks)
                              {
                                    $ObjNameCheck = “$objCheck”.replace(“[“,””).replace(“]”,””)                  

                                    $OutFileCheck = “$objpathChecks” + “$ObjName” + “.sql”

                                    $objCheck.Script($so)+”GO” | out-File $OutFileCheck -Append  
                                    
                              }   
                              
                                                         
                                $objpathForeignKeys = “$dbpath” + “Foreignkeys” + “\”

                                 if ( !(Test-Path $objpathForeignKeys))

                                        {$null=new-item -type directory -name “Foreignkeys”-path “$dbpath”}                           
                           
                              foreach ($objForeignKey in $objs.ForeignKeys)
                              {
                                    $ObjNameForeignKey = “$objForeignKey”.replace(“[“,””).replace(“]”,””)                  

                                    $OutFileForeignKey = “$objpathForeignKeys” + “$ObjName” + “.sql”

                                    $objForeignKey.Script($so)+”GO” | out-File $OutFileForeignKey -Append                                
                              }    
                              
                              #columns
                              $objpathDefaults = “$dbpath” + “DefaultConstraints” + “\”

                              if ( !(Test-Path $objpathDefaults))

                                   {$null=new-item -type directory -name “DefaultConstraints”-path “$dbpath”}   

                              foreach ($objcolumn in $objs.columns)
                              {
                                    #Write-Host $objcolumn
                                    foreach ($objcolumndefault in $objcolumn.DefaultConstraint)
                                    {
                                        $ObjNamecolumndefault = “$objcolumndefault”.replace(“[“,””).replace(“]”,””)                  

                                        $OutFilecolumndefault = “$objpathDefaults” + “$ObjName” + “.sql”

                                        $objcolumndefault.Script($so)+”GO” | out-File $OutFilecolumndefault -Append  
                                    }

                              }                           
                                                          
                           }



                      }
                    

              }

       }     

  }
}