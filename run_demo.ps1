# PowerShell Launcher for VQA Modal Analysis Live Demo App
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host " VQA MODAL ANALYSIS - LIVE CYBER-PHYSICAL SHM DEMONSTRATION APP" -ForegroundColor Yellow
Write-Host " COEP Technological University - End-Semester Project Evaluation" -ForegroundColor Green
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Starting Streamlit server..." -ForegroundColor White

& "C:\Users\yashg\AppData\Local\Python\bin\python.exe" -m streamlit run demo_app.py --server.headless false
