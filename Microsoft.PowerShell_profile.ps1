$env:Path += ";D:\Programs\;"
$env:Path += ";D:\Programs\platform-tools\;"

Set-Alias subl "D:\Programs\sublime_text\subl.exe"

Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
$PSOption =  @{
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
}
Set-PSReadLineOption @PSOption
Set-PSReadLineOption -Colors @{
    "Error" = "#B00020"
    "String" = "#a6e22e"

}