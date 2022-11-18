# Win11

* disable automatic update
* power plan: no sleep
* desktop bgcolor, desktop icon(ThisPc)
* add english languge
* feature: add linux, virtual platform
* remove ThisPc folders, fix dup drives in explorer
* 7-zip, chrome, qq pinyin
* remove useless programs
* setting->multitasking: disable snap next to it
* setting->start: off recently added apps, most used
* setting->taskbar: combine if full
* setting->region: calendar use lunar
* setting->ease access: keyboard: disable sticky keys
* setting->safesearch: off
* tidy notification panel
* start menu: tidy side icons
* system props: small dump, no remote assistance
* quick-access -> options: no folders, no files
* folder settings: group by none
* setting->system->notifications: disable suggestions on how to setup my device
* remove cdrom drive
* install wsl-ubuntu
    * always close wt window 
    * .gitconfig for user 1000
    * update-alternatives --config editor


# memo

* win11 install without TPM:
    * shift + F10: show cmd window

    * first:        REG ADD HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1
    * if NOT then:  REG ADD HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1

* win11 config startup without login with microsoft account:
    * shift + F10: show cmd window
    * windows/system32/oobe/oobeBypassNRO.cmd

