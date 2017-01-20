$ErrorActionPreference = 'Stop';

# Gather chocolatey install args
# Default values
$createDesktopIcon     = $true
$createQuickLaunchIcon = $true
$addContextMenuFiles   = $true
$addContextMenuFolders = $true
$addToPath             = $true

$arguments = @{}
$packageParameters = $env:chocolateyPackageParameters
if ($packageParameters)
{
      $match_pattern = "\/(?<option>([a-zA-Z]+)):(?<value>([`"'])?([a-zA-Z0-9- _\\:\.]+)([`"'])?)|\/(?<option>([a-zA-Z]+))"
      $option_name = 'option'
	  $value_name = 'value'
      if ($packageParameters -match $match_pattern )
      {
          $results = $packageParameters | Select-String $match_pattern -AllMatches
          $results.matches | % {
            $arguments.Add(
                $_.Groups[$option_name].Value.Trim(), 
                $_.Groups[$value_name].Value.Trim())
          }
      }
      else
        { Throw "Package Parameters were found but were invalid (REGEX Failure)" }

      if ($arguments.ContainsKey("nodesktopicon"))
      {
          Write-Host "nodesktopicon"
          $createDesktopIcon = $false
      }

      if ($arguments.ContainsKey("noquicklaunchicon")) 
      {
          Write-Host "noquicklaunchicon"
          $createQuickLaunchIcon = $false
      }

      if ($arguments.ContainsKey("nocontextmenufiles")) 
      {
          Write-Host "nocontextmenufiles"
          $addContextMenuFiles = $false
      }

      if ($arguments.ContainsKey("nocontextmenufolders")) 
      {
          Write-Host "nocontextmenufolders"
          $addContextMenuFolders = $false
      }
      
      if ($arguments.ContainsKey("dontaddtopath")) 
      {
          Write-Host "dontaddtopath"
          $addToPath = $false
      }
}
else
    { Write-Debug "No Package Parameters Passed in" }

# Format install args for the Visual Studio Code installer
$mergeTasks = "!runCode"
if ($createDesktopIcon)     { $mergeTasks = $mergeTasks + ",desktopicon"} 
if ($createQuickLaunchIcon) { $mergeTasks = $mergeTasks + ",quicklaunchicon" }
if ($addContextMenuFiles)   { $mergeTasks = $mergeTasks + ",addcontextmenufiles" }
if ($addContextMenuFolders) { $mergeTasks = $mergeTasks + ",addcontextmenufolders" }
if ($addToPath)             { $mergeTasks = $mergeTasks + ",addtopath" }

$packageName= 'VisualStudioCode-Insiders'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://az764295.vo.msecnd.net/insider/ee9d91c05fa571de56c41383cceee30b05b0a2f6/VSCodeSetup-1.9.0-insider.exe'
#$url64      = ''

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'exe'
  url           = $url
  url64bit      = $url64

  silentArgs   = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /mergetasks=$mergeTasks /log=`"$env:temp\vscode.log`"" # Inno Setup, plus args for Visual Studio Code installer
  validExitCodes= @(0)

  softwareName  = 'Visual Studio Code Insiders*'
}

Install-ChocolateyPackage @packageArgs

















