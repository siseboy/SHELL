:: --------------------------------------------------------------
::	��Ŀ: CloudflareSpeedTest �Զ����� Hosts
::	�汾: 1.0.0
::	����: XIU2
::	��Ŀ: https://github.com/XIU2/CloudflareSpeedTest
:: --------------------------------------------------------------
@echo off
Setlocal Enabledelayedexpansion

::�ж��Ƿ��ѻ�ù���ԱȨ��

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system" 

if '%errorlevel%' NEQ '0' (  
    goto UACPrompt  
) else ( goto gotAdmin )  

::д�� vbs �ű��Թ���Ա������б��ű���bat��

:UACPrompt  
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" 
    "%temp%\getadmin.vbs" 
    exit /B  

::�����ʱ vbs �ű����ڣ���ɾ��
  
:gotAdmin  
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )  
    pushd "%CD%" 
    CD /D "%~dp0" 


::�������ж��Ƿ��Ի�ù���ԱȨ�ޣ����û�о�ȥ��ȡ��������Ǳ��ű���Ҫ����


::��� nowip.txt �ļ������ڣ�˵���ǵ�һ�����иýű�
if not exist "nowip.txt" (
    echo �ýű�������Ϊ CloudflareST ���ٺ��ȡ��� IP ���滻 Hosts �е� Cloudflare CDN IP��
    echo ʹ��ǰ�����Ķ���https://github.com/XIU2/CloudflareSpeedTest/issues/42#issuecomment-768273768
    echo.
    echo ��һ��ʹ�ã����Ƚ� Hosts ������ Cloudflare CDN IP ͳһ��Ϊһ�� IP��
    set /p nowip="����� Cloudflare CDN IP ���س�������������Ҫ�ò��裩:"
    echo !nowip!>nowip.txt
    echo.
)  

::�� nowip.txt �ļ���ȡ��ǰ Hosts ��ʹ�õ� Cloudflare CDN IP
set /p nowip=<nowip.txt
echo ��ʼ����...
CloudflareST.exe -p 0
for /f "tokens=1 delims=," %%i in (result.csv) do (
    SET /a n+=1 
    If !n!==2 (
        SET bestip=%%i
        goto :END
    )
)
:END
echo %bestip%>nowip.txt
echo.
echo �� IP Ϊ %nowip%
echo �� IP Ϊ %bestip%
C:
CD "C:\Windows\System32\drivers\etc"
echo.
echo ��ʼ���� Hosts �ļ���hosts_backup��...
copy hosts hosts_backup
echo.
echo ��ʼ�滻...
(
    for /f "tokens=*" %%i in (hosts_backup) do (
        set s=%%i
        set s=!s:%nowip%=%bestip%!
        echo !s!
        )
)>hosts
echo ���...
echo.
pause 