param (
    [string]$crate = "",
    [Parameter(Mandatory=$true)][string]$git,
    [string]$tag = "",
    [string]$target = "",
    [string]$to = "$($env:USERPROFILE)\.cargo\bin",
    [boolean]$force = $false
)
$dest = $to

$td = ""

function say($msg) {
    Write-Host "install.ps1: $msg"
}

function say_err($msg) {
    Write-Verbose "install.ps1: $msg" -Verbose
}

function err($msg) {
    if($td -ne "") {
        Remove-Item -path $td -recurse
    }

    say_err($msg)
    exit(1)
}

function NewTemporaryDirectory {
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    New-Item -ItemType Directory -Path (Join-Path $parent $name)
}

$repo_url = "https://github.com/$git"
say_err "GitHub repository: $repo_url"

if ($crate -eq "") {
    $git_parts = $git -split "/"
    $crate = $git_parts[1]
}
say_err "Crate: $crate"

$releases_url = "$repo_url/releases"

if ($tag -eq "") {
    say_err "Finding tag from $releases_url/latest"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $latest_page = Invoke-WebRequest -Uri "$releases_url/latest" -MaximumRedirection 90 | Select-Object -ExpandProperty Content
    if ($latest_page -match "$releases_url/tag/(v[0-9.]*)") {
        $tag = $matches[1]
    } else {
        err("Could not extract tag from '$latest_page'")
    }
    say_err "Tag: latest ($tag)"
} else {
    say_err "Tag: $tag"
}

if ($target -eq "") {
    $rustc = rustc -Vv | Out-String
    if ($rustc -match "host: ([^ \r\n]*)") {
        $target = $matches[1]
    } else {
        err("Could not extract target from '$rustc'")
    }
}

say_err "Target: $target"

say_err "Installing to: $dest"
New-Item -ItemType directory -Path $dest -Force

$tarball = "$crate-$tag-$target.zip"
$download_url="$releases_url/download/$tag/$tarball"
say_err "Downloading: $download_url"

$td = NewTemporaryDirectory
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $download_url -OutFile "$td\$tarball"
Expand-Archive "$td\$tarball"  -DestinationPath $td

$exes = Get-ChildItem $td -Filter *.exe
foreach ($f in $exes) {
    $path = (Join-Path $dest $f)
    if ((Test-Path $path) -and !$force) {
        err "$f already exists in $dest"
    } else {
        New-Item -ItemType directory -Path $dest -Force
        Copy-Item $f -Destination $dest
    }
}

Remove-Item -path $td -recurse

Get-ChildItem $dest
