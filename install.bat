@echo off
rem Installs the global agent instructions from this repo. Safe to re-run:
rem updates what it installed and asks before touching anything else.
setlocal EnableExtensions

set "REPO=%~dp0"
set "REPO=%REPO:~0,-1%"
set "REPO_FWD=%REPO:\=/%"
set "IMPORT=@%REPO_FWD%/claude-global.md"

call :claude
call :stray
call :codex
echo Done. Verify with /memory in a new Claude Code session.
exit /b 0

rem Claude Code: import claude-global.md from %USERPROFILE%\.claude\CLAUDE.md
:claude
set "CLAUDE_MD=%USERPROFILE%\.claude\CLAUDE.md"
if not exist "%USERPROFILE%\.claude\" mkdir "%USERPROFILE%\.claude"
set "size=0"
if exist "%CLAUDE_MD%" for %%F in ("%CLAUDE_MD%") do set "size=%%~zF"
if "%size%"=="0" (
  >"%CLAUDE_MD%" echo(%IMPORT%
  echo Claude: created %CLAUDE_MD%
  exit /b 0
)
rem findstr /x fails on LF-only files, so compare lines with .NET instead.
powershell -NoProfile -Command "if ([IO.File]::ReadAllLines($env:CLAUDE_MD) -contains $env:IMPORT) { exit 0 } else { exit 1 }" && (
  echo Claude: up to date
  exit /b 0
)
findstr /r /c:"^@.*/claude-global\.md" "%CLAUDE_MD%" >nul && goto claude_update
echo WARNING: %CLAUDE_MD% already has content (%size% bytes).
call :confirm "Append the import line?" || (
  echo Claude: skipped. Add this line manually: %IMPORT%
  exit /b 0
)
copy /y "%CLAUDE_MD%" "%CLAUDE_MD%.bak" >nul
>>"%CLAUDE_MD%" echo(
>>"%CLAUDE_MD%" echo(%IMPORT%
echo Claude: appended import (backup: %CLAUDE_MD%.bak)
exit /b 0

:claude_update
copy /y "%CLAUDE_MD%" "%CLAUDE_MD%.bak" >nul
powershell -NoProfile -Command "$p=$env:CLAUDE_MD; $l=[IO.File]::ReadAllLines($p) -replace '^@.*/claude-global\.md\s*$', $env:IMPORT; [IO.File]::WriteAllLines($p, $l)"
echo Claude: updated import path (backup: %CLAUDE_MD%.bak)
exit /b 0

:stray
if exist "%USERPROFILE%\.claude\AGENTS.md" echo WARNING: %USERPROFILE%\.claude\AGENTS.md exists. Claude Code doesn't load it at user level; merge it into this repo or remove it.
exit /b 0

rem Codex: copy AGENTS.md (symlinks need admin or Developer Mode). The stamp
rem records the installed copy so unedited copies can be updated without asking.
:codex
set "CODEX=%USERPROFILE%\.codex"
set "SRC=%REPO%\AGENTS.md"
set "DST=%CODEX%\AGENTS.md"
set "STAMP=%CODEX%\.agents-md-installed"
if not exist "%CODEX%\" (
  echo Codex: %CODEX% not found, skipping
  exit /b 0
)
if exist "%CODEX%\AGENTS.override.md" echo WARNING: %CODEX%\AGENTS.override.md exists and takes precedence over AGENTS.md.
if not exist "%DST%" (
  call :codex_copy
  echo Codex: installed %DST%
  exit /b 0
)
fc /b "%DST%" "%SRC%" >nul && (
  copy /y "%SRC%" "%STAMP%" >nul
  echo Codex: up to date
  exit /b 0
)
if exist "%STAMP%" fc /b "%DST%" "%STAMP%" >nul && (
  call :codex_copy
  echo Codex: updated %DST%
  exit /b 0
)
echo WARNING: %DST% differs from this repo's AGENTS.md (local edits or another file).
call :confirm "Replace it (backup to AGENTS.md.bak)?" || (
  echo Codex: skipped
  exit /b 0
)
copy /y "%DST%" "%DST%.bak" >nul
call :codex_copy
echo Codex: replaced %DST%
exit /b 0

:codex_copy
copy /y "%SRC%" "%DST%" >nul
copy /y "%SRC%" "%STAMP%" >nul
exit /b 0

:confirm
set "ans="
set /p "ans=%~1 [y/N] "
if /i "%ans%"=="y" exit /b 0
if /i "%ans%"=="yes" exit /b 0
exit /b 1
