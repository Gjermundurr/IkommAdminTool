# IKOMMADMINTOOL by Jerry.
#
#

### FUNCTIONS

function IAT-uptime {
    param(
        $server
    )

    $remoteBlock = {systeminfo}

    if ($server) {
        $sysinfoDump = Invoke-Command -ComputerName $server -ScriptBlock $remoteBlock
    }
    else {
        $sysinfoDump = systeminfo
    }

    $SystemBootString = (Select-String -InputObject $sysinfoDump -Pattern "System Boot Time:\s+\d\d\.\d\d\.\d\d\d\d,\s\d\d:\d\d:\d\d").Matches.Value
    $datetimeString = (Select-String -InputObject $SystemBootString -Pattern "\d\d\.\d\d\.\d\d\d\d,\s\d\d:\d\d:\d\d").Matches.Value
    
    # Return uptime of server.
    Write-Output ('System Boot Time: {0}' -f $datetimeString)
    $datetimeString | New-TimeSpan
} # end function

function IAT-query {
    param(
        $server
    )

    $block = {quser}
    if ($server) {
        $ret = invoke-command -ComputerName $server -ScriptBlock $block
    }
    else {
        $ret = quser
    }
    
    return $ret
} # end fuction

function IAT-power {
    param(
        $server,
        [switch]$off,
        [switch]$restart
    )

    $restartblock = {shutdown /r -t 5}
    $offBlock = {shutdown /s -t 5}

    if ($off) {
        invoke-command -ComputerName $server -ScriptBlock $restartblock
        $retstring = 'Powering off $($server)'
    }
    if ($restart) {
        invoke-command -ComputerName $server -ScriptBlock $offBlock
        $retstring = 'Restarting $($server) ...'
    }

    return $retstring
    
} # end function

function IAT-shared {
    param(
        $server
    )

    $block = {Get-SmbShare}
    if ($server) {
        $ret = invoke-command -ComputerName $server -ScriptBlock $block
    }
    else {
        $ret = get-smbshare
    }
    
    return $ret
} # end function


$help = @"
USAGE:
    server [hostname] : set target server
"@


# print hello messsage.
write-output 'IKOMMADMINTOOL by Jerry the Powershell Terrorist.'
$targetServer = 'localhost'

do {

    # HOT VARIABLES
    $CmdLine = 'target>' + $targetServer + '>'

    $menu = @"
-----------------# Menu #-----------------

TARGET: $($targetServer)

1) uptime                : Display uptime of server.
2) users                 : List connected users.
3) shares                : Display shared folders and Drives.
4) power [restart|off]   : restart target server.
5) hack                  : hack the goverment
6)

x) reset                 : Remove target configuration.
7) menu                  : Display menu options.
8) quit                  : Exit program.
-------------------------------------------

"@
    # READ INPUT
    $inp = read-host $cmdLine

    if ($inp -eq 'menu') {
        # print menu
        write-output $menu
    }
    elseif ($inp -eq 'help') {
        Write-Output $help
    }
    elseif ($inp -eq 'uptime') {
        IAT-uptime -server $targetServer
    }
    elseif ($inp -match 'power') {
        $mode = $inp.split(' ')[1]
        if ($mode -eq 'restart') {IAT-power -restart -server $targetServer}
        elseif ($mode -eq 'off') {IAT-power -off -server $targetServer}
        else {Write-host -ForegroundColor Red 'Invalid parameter(s).'}
    }
    elseif ($inp -match 'target') {
        $targetServer = $inp.Split(' ')[1]
    }
    elseif ($inp -match 'reset') {
        $targetServer = 'localhost'
    }
    elseif ($inp -match 'users') {
        IAT-query -server $targetServer
    }
    elseif ($inp -eq 'shares') {
        IAT-shared -server $targetServer
    }
    else {
        Write-host -ForegroundColor Red 'Invalid parameter(s).'
    }
    # read input
} while ($inp -ne 'quit')
# goodbye my dear User.
Write-Output "...`nGoodbye!"