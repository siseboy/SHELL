:: --------------------------------------------------------------
::	��Ŀ: CloudflareSpeedTest �Զ����� 3Proxy
::	�汾: 1.0.1
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
if not exist "nowip_3proxy.txt" (
    echo �ýű�������Ϊ CloudflareST ���ٺ��ȡ��� IP ���滻 3Proxy �����ļ��е� Cloudflare CDN IP��
    echo ���԰����� Cloudflare CDN IP ���ض�������� IP��ʵ��һ�����ݵļ�������ʹ�� Cloudflare CDN ����վ������Ҫһ������������� Hosts �ˣ���
    echo ʹ��ǰ�����Ķ���https://github.com/XIU2/CloudflareSpeedTest/discussions/71
    echo.
    set /p nowip="���뵱ǰ 3Proxy ����ʹ�õ� Cloudflare CDN IP ���س�������������Ҫ�ò��裩:"
    echo !nowip!>nowip_3proxy.txt
    echo.
)  

::�� nowip_3proxy.txt �ļ���ȡ��ǰʹ�õ� Cloudflare CDN IP
set /p nowip=<nowip_3proxy.txt
echo ��ʼ����...



:: ��������Լ���ӡ��޸� CloudflareST �����в�����Ĭ�ϵ� -p 0 ��Ϊ�˱����������Ҫ �س��� ���ܼ���������
CloudflareST.exe -p 0



for /f "tokens=1 delims=," %%i in (result.csv) do (
    set /a n+=1 
    If !n!==2 (
        set bestip=%%i
        goto :END
    )
)
:END
echo %bestip%>nowip_3proxy.txt
echo.
echo �� IP Ϊ %nowip%
echo �� IP Ϊ %bestip%



:: �뽫�����ڵ� D:\Program Files\3Proxy ��Ϊ��� 3Proxy ��������Ŀ¼
CD /d "D:\Program Files\3Proxy"
:: ��ȷ�����иýű�ǰ���Ѿ����Թ� 3Proxy �����������в�ʹ�ã�



echo.
echo ��ʼ���� 3proxy.cfg �ļ���3proxy.cfg_backup��...
copy 3proxy.cfg 3proxy.cfg_backup
echo.
echo ��ʼ�滻...
(
    for /f "tokens=*" %%i in (3proxy.cfg_backup) do (
        set s=%%i
        set s=!s:%nowip%=%bestip%!
        echo !s!
        )
)>3proxy.cfg

net stop 3proxy
net start 3proxy

echo ���...
echo.
pause 