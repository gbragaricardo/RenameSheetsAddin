# Identifica a raiz do repositório (RenameSheetsAddin)
$repoRoot = $PSScriptRoot
if (-not (Test-Path (Join-Path $repoRoot "RenameSheets.Addin.csproj"))) {
    $repoRoot = "C:\dev\revit_complements\RenameSheetsAddin"
}

$projectDir = $repoRoot
$csprojPath = Join-Path $projectDir "RenameSheets.Addin.csproj"
$addinManifest = Join-Path $projectDir "RenameSheets.addin"
$binReleaseDir = Join-Path $projectDir "bin\Release"
$releasesDir = Join-Path $repoRoot "Releases"

# Anos do Revit para gerar build
$revitYears = @("2022", "2023", "2024", "2025", "2026")

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Iniciando Build para versões do Revit..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Compila para cada versão do Revit em modo Release
foreach ($year in $revitYears) {
    Write-Host "`n[+] Compilando para Revit $year (Release)..." -ForegroundColor Yellow
    
    $buildResult = dotnet build "$csprojPath" -c Release -p:RevitYear=$year --nologo
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[-] Falha ao compilar para Revit $year!" -ForegroundColor Red
        Write-Host $buildResult
        exit $LASTEXITCODE
    } else {
        Write-Host "[OK] Revit $year compilado com sucesso." -ForegroundColor Green
    }
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "Organizando arquivos na pasta Releases..." -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 2. Cria a pasta 'Releases' na raiz do repo se ela não existir
if (-not (Test-Path $releasesDir)) {
    New-Item -ItemType Directory -Path $releasesDir | Out-Null
    Write-Host "Pasta 'Releases' criada em: $releasesDir" -ForegroundColor Cyan
}

# 3. Organiza cada versão compilada
foreach ($year in $revitYears) {
    $sourceYearDir = Join-Path $binReleaseDir $year
    $targetYearDir = Join-Path $releasesDir $year

    if (-not (Test-Path $sourceYearDir)) {
        Write-Host "[-] Pasta de origem não encontrada: $sourceYearDir" -ForegroundColor Yellow
        continue
    }

    # Se já existir, remove para cópia limpa
    if (Test-Path $targetYearDir) {
        Remove-Item -Path $targetYearDir -Recurse -Force
    }

    # Cria a pasta do ano dentro de Releases (ex: Releases/2024)
    New-Item -ItemType Directory -Path $targetYearDir | Out-Null

    # Cria a subpasta RenameSheets (ex: Releases/2024/RenameSheets)
    $targetRenameSheetsDir = Join-Path $targetYearDir "RenameSheets"
    New-Item -ItemType Directory -Path $targetRenameSheetsDir | Out-Null

    # Copia todo o conteúdo de bin/Release/<ano> para dentro de Releases/<ano>/RenameSheets
    Copy-Item -Path "$sourceYearDir\*" -Destination $targetRenameSheetsDir -Recurse -Force

    # Copia o arquivo de manifesto RenameSheets.addin para a pasta Releases/<ano>
    if (Test-Path $addinManifest) {
        Copy-Item -Path $addinManifest -Destination $targetYearDir -Force
    }

    Write-Host "[OK] Versão $year organizada com sucesso em: $targetYearDir" -ForegroundColor Green
}

Write-Host "`n========================================================" -ForegroundColor Green
Write-Host "Organização de Releases concluída com sucesso em: $releasesDir" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green