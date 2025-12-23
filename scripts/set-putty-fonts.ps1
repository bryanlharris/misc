$base = "HKCU:\Software\SimonTatham\PuTTY\Sessions"
Get-ChildItem $base | ForEach-Object {
    Set-ItemProperty $_.PsPath Font "Cascadia Mono"
    Set-ItemProperty $_.PsPath FontHeight 12
    Set-ItemProperty $_.PsPath FontIsBold 0
}
