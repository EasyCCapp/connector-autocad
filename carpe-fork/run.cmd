@echo off
rem -----------------------------------------------------------------
rem AutoCAD MCP connector launcher
rem
rem Carpe spawns this from connector.json's distribution.launch.command.
rem  - %~dp0 is the directory the unzipped connector sits in
rem    (~/.easycc/connectors/autocad/<version>/).
rem  - The bundled venv is at .venv/ inside that directory.
rem  - server.py and the rest of the upstream source are also there.
rem
rem stdin/stdout carry MCP protocol traffic. stderr is for logs only.
rem -----------------------------------------------------------------

setlocal
set "CONNECTOR_DIR=%~dp0"
set "PYTHON_EXE=%CONNECTOR_DIR%.venv\Scripts\python.exe"
set "SERVER_PY=%CONNECTOR_DIR%server.py"

if not exist "%PYTHON_EXE%" (
    echo [autocad-mcp] Bundled Python not found at %PYTHON_EXE% 1>&2
    exit /b 1
)

if not exist "%SERVER_PY%" (
    echo [autocad-mcp] server.py not found at %SERVER_PY% 1>&2
    exit /b 1
)

rem Carpe sets ALLOWED_PATHS, AUTOCAD_MCP_BACKEND, and DANGEROUS_COMMANDS_ENABLED
rem in the env before invoking us. Don't override here.

"%PYTHON_EXE%" "%SERVER_PY%"
exit /b %ERRORLEVEL%
