param([int]$Port = 5173, [string]$Root = (Join-Path (Split-Path $PSScriptRoot) 'app'))
$ErrorActionPreference = 'Stop'
$types = @{ '.html' = 'text/html; charset=utf-8'; '.js' = 'text/javascript; charset=utf-8'; '.css' = 'text/css; charset=utf-8'; '.png' = 'image/png'; '.svg' = 'image/svg+xml'; '.json' = 'application/json' }
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "serving $Root on http://localhost:$Port/"
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
    $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ($path -eq '') { $path = 'index.html' }
    $file = Join-Path $Root $path
    $res = $ctx.Response
    $res.Headers.Add('Cache-Control', 'no-store')
    if ((Test-Path -LiteralPath $file -PathType Leaf) -and ([IO.Path]::GetFullPath($file).StartsWith([IO.Path]::GetFullPath($Root)))) {
        $bytes = [IO.File]::ReadAllBytes($file)
        $ext = [IO.Path]::GetExtension($file).ToLower()
        $res.ContentType = $(if ($types.ContainsKey($ext)) { $types[$ext] } else { 'application/octet-stream' })
        $res.ContentLength64 = $bytes.Length
        if ($ctx.Request.HttpMethod -ne 'HEAD') { $res.OutputStream.Write($bytes, 0, $bytes.Length) }
    }
    else { $res.StatusCode = 404 }
    $res.OutputStream.Close()
    } catch { Write-Host "request failed: $($_.Exception.Message)"; try { $ctx.Response.Abort() } catch {} }
}
