@echo off
title OBIN Real-Time Cloud Sync (Telegram & Google Sheet)
cd /d "c:\wabsite\anti 2"
echo ========================================================
echo       OBIN REAL-TIME CLOUD SYNC DAEMON
echo       Telegram Bot: @OBIN_USER_Bot
echo       Group: OBIN_USER_GR
echo ========================================================
node services/obin_cloud_sync.mjs
pause
