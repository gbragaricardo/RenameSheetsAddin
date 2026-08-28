# Define os caminhos baseados na raiz que você passou
$repoRoot = "c:\dev\revit_complements"
$releasesDir = Join-Path $repoRoot "Releases"
$sourceDir = Join-Path $repoRoot "RenameSheetsAddin\bin\Release"

# 1. Cria a pasta 'Releases' na raiz do repo se ela ainda não existir
if (-not (Test-Path $releasesDir)) {
    New-Item -ItemType Directory -Path $releasesDir | Out-Null
    Write-Host "Pasta 'Releases' criada na raiz." -ForegroundColor Cyan
}

# Verifica se o build gerou a pasta Release
if (-not (Test-Path $sourceDir)) {
    Write-Host "A pasta $sourceDir não foi encontrada. Tem certeza que o build foi feito?" -ForegroundColor Red
    exit
}

# 2. Pega todas as pastas dentro de bin\Release (provavelmente as pastas de versão do Revit, ex: 2022, 2023, 2024...)
$pastasRelease = Get-ChildItem -Path $sourceDir -Directory

foreach ($pasta in $pastasRelease) {
    $nomePasta = $pasta.Name
    $destinoPasta = Join-Path $releasesDir $nomePasta
    
    # Se já existir uma versão anterior na pasta Releases, remove para garantir uma cópia nova e limpa
    if (Test-Path $destinoPasta) {
        Remove-Item -Path $destinoPasta -Recurse -Force
    }

    # 3. Copia a pasta inteira de bin\Release para dentro de Releases
    Copy-Item -Path $pasta.FullName -Destination $destinoPasta -Recurse -Force
    
    # 4. Entra na pasta recém-copiada e cria a subpasta 'RenameSheets'
    $pastaRenameSheets = Join-Path $destinoPasta "RenameSheets"
    New-Item -ItemType Directory -Path $pastaRenameSheets | Out-Null
    
    # 5. Move todo o conteúdo para dentro de 'RenameSheets'
    # Ele pega tudo o que está na pasta (dlls, addin, etc), ignorando apenas a própria pasta 'RenameSheets' recém-criada
    $itensParaMover = Get-ChildItem -Path $destinoPasta | Where-Object { $_.Name -ne "RenameSheets" }
    
    foreach ($item in $itensParaMover) {
        Move-Item -Path $item.FullName -Destination $pastaRenameSheets -Force
    }
    
    Write-Host "Processada a pasta: $nomePasta" -ForegroundColor Green
}

Write-Host "Organização de Releases concluída com sucesso!" -ForegroundColor Green