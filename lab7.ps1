# Lab7 user creator 
# kellan cook
# cook0319@algonquinlive.com
#
#
#


#function for updating the log files
function LogUpdate {
    param (
        $output
    )
    $date = Get-Date
    Add-Content -Path "./$global:logname" -Value "$date USER: $ENV:USERNAME $output"
}

#function for creating 1 user at a time asking for username and password
function CreateUser {
    LogUpdate -output "Started Create User"
    #gets input username from user
    $a = Read-Host "Enter UserName: "
    #checks if a user with the given name exits if not creates user
    try {
        Get-LocalUser $a -ErrorAction Stop
        $count = Get-LocalUser $a | Measure-Object -Line | Select-Object -ExpandProperty "lines"
        if ($count -ne "0") {
            Write-Output "User Already exists"
            LogUpdate -output "[ERROR] attempted to create user $a user already exists"
        }
    }
    catch [Microsoft.PowerShell.Commands.UserNotFoundException]{
        $b = Read-Host -AsSecureString "Enter Password"
        $date = Get-Date
        New-LocalUser -FullName $a -Name $a -Password $b -Description "user created at $date"
        Add-LocalGroupMember -Group "Users" -Member $a
        LogUpdate -output "Created User $a"
    }
}

#function for deleting 1 user at a time off a list of users
function DeleteUser {
    LogUpdate -output "Started Remove User"
    $users = Get-LocalUser | Select-Object -Expand Name
    $i = 0
    #prints out all users sequentialy with array index for easy selection
    foreach($user in $users){
        Write-Output "$i - $user"
        $i = $i + 1
    }
    $a = Read-Host "Enter User Number"
    #checks if the user exists
    try {
        Get-LocalUser $users[$a] -ErrorAction Stop
    }
    catch [Microsoft.PowerShell.Commands.UserNotFoundException]{
        Write-Output "[Error] User Does not exist"
        return
    }
    #gives user option to delete home directory of selected user
    $b = Read-Host "would you like to delete the users home Directory? (yes/no)"
    $choice = $users[$a]
    if($b -eq "yes"){
        
        #trys to delete directory if it does not exist gives error message and moves on
        try {
            Remove-Item -Recurse -Force -LiteralPath "C:\Users\$choice" -ErrorAction Stop
            LogUpdate -output "user $choice home directory deleted"
        }
        catch{
            Write-Output "$choice dose not have a home directory"
            LogUpdate -output "attempted to delete user $choice home directory however directory does not exist"
        }
    }
    #removes the local user
    try{
    Remove-LocalUser $choice
    }
    catch{
    write-output "unkown choice error"
    LogUpdate -output "failed to delete $choice"
    }
    LogUpdate -output "user $choice deleted"
}

#function for creating 100 incremental users from user00 to user99
function 100Users {
    $i = 0
    #performs the operation while i is less then 100
    while($i -le 99){
        $usernumber = '{0:d2}' -f $i
        $username = "user$usernumber"
        $Password = ConvertTo-SecureString -AsPlainText -Force "gTWnT&2TzzESwH6fze&TYEDF2^!2gqq&ZF"
        Write-Output "created - $username"
        #trys to create user if user already exists shows error and moves on
        try {
            New-LocalUser -Name $username -Password $Password -ErrorAction Stop | out-null
            LogUpdate -output "user $username created"
        }
        catch {
            Write-Output "User $username already exists"
            LogUpdate -output "attempted to create user $username - user already exists"
        }
        $i = $i + 1
    }
    LogUpdate -output "100 sequential users created user 00 to user 99"
}

#function for deleting 100 incremental users from user00 to user99
function Delete100 {
        $b = Read-Host "would you like to delete the users home Directory? (yes/no)"
        $i = 0
        #performs function while i is less then 100
        while($i -le 99){
            $usernumber = '{0:d2}' -f $i
            $username = "user$usernumber"
            Write-Output "deleted - $username"
            #attemps to remove user if it cant throws error user does not exist
            try {
                Remove-LocalUser -Name $username -ErrorAction Stop
                LogUpdate -output "user $username deleted"
            }
            catch {
                Write-Output "User $username does not exists"
                LogUpdate -output "attempted to delete user $username - user does not exists"
            }
            #attemps to delete home directory if user slected yes
            if($b -eq "yes"){
            
                try {
                    Remove-Item -Recurse -Force -LiteralPath "C:\Users\$username" -ErrorAction Stop
                    LogUpdate -output "user $username home directory deleted" 
                }
                catch{
                    Write-Output "$username dose not have a home directory"
                    LogUpdate -output "attempted to delete user $username home directory however directory does not exist"
                }
            }
            $i = $i + 1
        }
        LogUpdate -output "100 sequential users deleted user 00 to user 99"       
}

#function for creating users from a csv file
function UsersfromFile {
    $path = Read-Host "what is the path of the user file?"
    #creates the user list from the csv file
    $userlist = Get-Content $path | Select-Object -Skip 1
    #for each user in file creates a user
    foreach($user in $userlist){
        $user = $user -split ','
        $name = $user[0] + $user[1]
        $Password = ConvertTo-SecureString -AsPlainText -Force "gTWnT&2TzzESwH6fze&TYEDF2^!2gqq&ZF"
        try{
        New-LocalUser -name $user[2] -Password $Password | Out-Null
        }
        catch{
            Write-Output
        }
        try{
            Add-LocalGroupMember -Member $user[2] -Group $user[3] -ErrorAction Stop
        }
        catch [Microsoft.PowerShell.Commands.AddLocalGroupMemberCommand]{
            New-LocalGroup -Name $user[3]
            Add-LocalGroupMember -Member $user[2] -Group $user[3]
        }
        try{
            Add-LocalGroupMember -Member $user[2] -Group $user[4] -ErrorAction Stop
        }
        catch [Microsoft.PowerShell.Commands.AddLocalGroupMemberCommand]{
            New-LocalGroup -Name $user[4]
            Add-LocalGroupMember -Member $user[2] -Group $user[5]
        }
        LogUpdate -output "created user: $name as user: " + $user[2]
    }
}
function Main{

    write-output "Logs can be found at ./$global:logname"
    Write-Output "*******************"
    Write-Output " Main Menu Options"
    Write-Output "*******************"
    Write-Output "1 - Create new user"
    Write-Output "2 - delete user"
    Write-Output "3 - create 100 users"
    Write-Output "4 - create users from file"
    Write-Output "5 - Remove 100 users"
    $a = Read-Host "what would you like to do?"
    switch ($a) {
        1 { 
            CreateUser 
        }
        2 { 
            DeleteUser
        }
        3 { 
            100Users
        }
        4 { 
            UsersfromFile
        }
        5 {
            Delete100
        }
        Default {}
    }
}
#startup info
$ENV:USERNAME
$date = Get-Date
Write-Output $date
$date = $date -replace '[:''"]'
$global:logname = "LOG-$ENV:USERNAME-$date.log"
$null = New-Item -ItemType File -Name "./$global:logname"
Add-Content -Path "./$global:logname" -Value $date
Add-Content -Path "./$global:logname" -Value $ENV:USERNAME
try {
    while ($true) {
        Main
    }
}
finally {
    LogUpdate -output "exited program"
}