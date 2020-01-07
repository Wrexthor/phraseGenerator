<#
.SYNOPSIS
Random phrase generator
.DESCRIPTION
Generates custom length passphrase with optional custom wordlist
uses mixedcase words and random number insertations to increase complexity
writes to console and pastes to clipboard if specified
.PARAMETER Length
Determines the minimum length of the generated passphrase
Can generate between 12 and 1024 minimum char passphrase
.PARAMETER OutClipboard
Outputs the passphrase to the computers clipboard.
.PARAMETER WordList
Path to custom wordlist for use in phrases
.EXAMPLE
Get-PassPhrase -length 64
.EXAMPLE
Get-PassPhrase -length 128 -wordlist C:\temp\words.txt -OutClipboard
.NOTES
Author: Jack Swedjemark
Updated: 07-01-2020
#>
[CmdletBinding()]
param(
# Length parameter
[Parameter(Position=0)]    
[ValidateRange(12,1024)]
[ValidateNotNull()]  
[Int]$length = 32,
# Wordlist parameter
[Parameter(Position=1)]
[ValidateScript({Test-Path $_})]
[string]$WordList = "$PSScriptRoot\words.txt",
    
# Determine if result should be put to clipboard
[parameter(Mandatory=$false)]
[Switch]
$OutClipboard
)
$path = $wordlist
# verbose output
if ($length -eq 32)
    {Write-debug "Default is 32 characters, specify -length for custom length."}    

# get words from file
if (test-path $path)
{
    $words = get-content $path
}
else
{
    write-host "words.txt file not found, please make sure it is present in same folder as script" -for red
}
$pw = $null
# while less than length, add words and spaces
while ($pw.Length -lt $length) {
    if ($pw -notlike $null) {        
        # add numbers randomly to end or beginning of words to increase complexity        
        $randTemp = get-random -maximum 10
        # end of word
        if ($randTemp % 2) {
            $randNumber = get-random -minimum 2 -maximum 9
            $pw += "$($randNumber.ToString())"
            $pw += " "
        }
        # begining of word
        elseif ($randTemp % 3) {
            $randNumber = get-random -minimum 2 -maximum 9
            $pw += " "
            $pw += "$($randNumber.ToString())"            
        }
        # just add space
        else
        {
            $pw += " "
        }        
    }
    # get random word from wordlist
    $rand = Get-Random -Maximum ($words.count -1)
    # use secondary random value to avoid some words always being altered
    $randUpper = get-random -maximum 1000
    # if random divisible by 2, make some characters uppercase
    if ($randUpper % 2)
    {        
        $newString = ""
        # convert string to chararray
        $charArray =  $words[$rand].ToCharArray()
        # iterate and convert random chars to upper and add to temp var
        foreach ($char in $charArray) {
            if ((get-random -maximum 10) % 7){
                $newString += $char.ToString().ToUpper()          
            }
            else
            {
                $newString += $char
            }
        }
        # add to passphrase
        $pw += $newString
    }
    # just add the word without altering it
    else {
        $pw += $words[$rand]
    }
}

write-host "Your new passphrase is:"
write-host "$pw `n" -ForegroundColor Yellow
if ($OutClipboard) {
    $pw | clip.exe
    Write-Host "Passphrase has been copied to clipboard."
}
# remove variable once function has run
Remove-Variable -Name pw