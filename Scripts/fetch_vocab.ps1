# 说明：下载 ORB 词典到 Vocabulary/ORBvoc.txt（引用上游公开直链）
# 使用：powershell -ExecutionPolicy Bypass -File scripts\fetch_vocab.ps1

param(
    [string]$OutDir = "Vocabulary"
)

$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# 首选直链（可按需调整为你仓库的 Release 地址）
$candidates = @(
    # ORB-SLAM3 仓库（约 50MB 纯文本）
    'https://github.com/UZ-SLAMLab/ORB_SLAM3/raw/master/Vocabulary/ORBvoc.txt',
    # ORB-SLAM2 压缩版（约 27MB，需解压得到 txt）
    'https://github.com/raulmur/ORB_SLAM2/raw/master/Vocabulary/ORBvoc.txt.tar.gz'
)

$dstTxt = Join-Path $OutDir 'ORBvoc.txt'
$tmpDir = Join-Path $OutDir '.tmp'
New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null

function Expand-GzipTar($file, $outputDir){
    # 借助 tar 解压 .tar.gz（Windows 10+ 自带 bsdtar）
    tar -xzf $file -C $outputDir
}

Write-Host "开始下载 ORB 词典…" -ForegroundColor Cyan

$downloaded = $false
foreach($url in $candidates){
    try{
        $name = Split-Path $url -Leaf
        $tmp = Join-Path $tmpDir $name
        Write-Host "尝试: $url" -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
        if($name -like '*.tar.gz'){
            Expand-GzipTar -file $tmp -outputDir $tmpDir
            $tarTxt = Join-Path $tmpDir 'ORBvoc.txt'
            if(Test-Path $tarTxt){ Copy-Item $tarTxt $dstTxt -Force; $downloaded = $true; break }
        }elseif($name -like '*.txt'){
            Copy-Item $tmp $dstTxt -Force; $downloaded = $true; break
        }
    }catch{ Write-Host "失败: $url -> $($_.Exception.Message)" -ForegroundColor Yellow }
}

if(-not $downloaded){ throw '所有来源下载失败，请检查网络或更换镜像。' }

Write-Host "已保存：$dstTxt" -ForegroundColor Green
Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue

