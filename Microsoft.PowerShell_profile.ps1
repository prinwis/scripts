$env:Path += ";D:\Programs\;"
$env:Path += ";D:\Programs\platform-tools\;"

Set-Alias subl "D:\Programs\sublime_text\subl.exe"

Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
Set-PSReadLineOption -BellStyle None
# Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

$PSOption =  @{
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
}

Set-PSReadLineOption @PSOption
Set-PSReadLineOption -Colors @{
    "Error" = "#B00020"
    "String" = "#a6e22e"
}

function prompt {
    "$([char]0x1b)[38;2;0;150;255m$(Get-Location)> $([char]0x1b)[0m"
}