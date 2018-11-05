[CmdletBinding()]
param (
   [parameter(Mandatory = $True, ValueFromPipeline = $True,
                    HelpMessage = 'Name of file to have signature calculated.')]
   [string] $file = '',

   [parameter(Mandatory = $False, ValueFromPipeline = $False,
                    HelpMessage = 'Optional offset into file to start signature calculation.')]
   [int] $offsetStart = 0,

   [parameter(Mandatory = $False, ValueFromPipeline = $False,
                    HelpMessage = 'Optional length to limit number of bytes used in signature calculation.')]
   [int] $lengthOverride = 0,

   [parameter(Mandatory = $False, ValueFromPipeline = $False,
                    HelpMessage = 'Optional length to limit number of bytes used in signature calculation.')]
   [bool] $silent = $false
)

$pathHelper = $ExecutionContext.SessionState.Path
$path = Join-Path -ChildPath $file -Path $pathHelper.CurrentLocation
$bytes = [System.IO.File]::ReadAllBytes($path)
if ($lengthOverride -ne 0 -or $offsetStart -ne 0)
{
    if ($lengthOverride -eq 0)
    {
        $lengthOverride = $bytes.Count - 1
    }
    $offsetEnd = $offsetStart + $lengthOverride - 1
    $bytes = $bytes[$offsetStart..$offsetEnd]

    if ($silent -eq $false)
    {
        Write-Host "Calculating partial file hash from Offset: $offsetStart Length: $($bytes.Count)"
    }
}
else
{
    if ($silent -eq $false)
    {
        Write-Host "Calculating full file hash from file of Length: $($bytes.Count)"
    }
}


$numArray = [System.Byte[]]::new(16)
for($i = 0; $i -lt $numArray.Count; ++$i)
{
    $numArray[$i] = 0
}

$numArray2 = @(6, 8, 11, 15, 0)
[int] $iNumArray2Last = $numArray2.Count - 1
[int] $sig = 0;			
  
foreach($byte in $bytes)
{
    for($iNumArrary2 = 0 ; $iNumArrary2 -le $iNumArray2Last; $iNumArrary2++)
    {
       [int] $index = $numArray2[$iNumArrary2]
       if($iNumArrary2 -eq $iNumArray2Last)
       {
            $numArray[$index] = $byte
       }
       else
       {			
          $byte = $numArray[$index] -bxor $byte
       }

       if(--$index -lt 0)
       {
         $index = $numArray.Count - 1
       }

       $numArray2[$iNumArrary2] = $index
    } 

}

[int] $sig = 0
foreach ($byte in $numArray)
{
    $b = $byte
    for($bit = 0; $bit -lt 8; $bit++)
    {
      $sig = ($sig -shl 1) -bor (($b -bxor ((($sig -shr 6) -bxor ($sig -shr 8) -bxor ($sig -shr 11) -bxor ($sig -shr 15))) -band 1))
      $b = $b -shr 1
      }
  }

  $sig = $sig -band 0xFFFF
  if ($silent -eq $true)
  {
      return $sig
  }

  Write-Host ('{0:X4}' -f $sig)