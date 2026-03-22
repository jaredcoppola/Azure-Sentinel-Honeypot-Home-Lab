# Azure Sentinel & Cyber Attack Map

### 🛡️ Project Overview
This project involves the deployment of a cloud-native **SIEM (Microsoft Sentinel)** linked to a live Windows honeypot. The primary goal was to observe and analyze real-time RDP brute-force attacks from global threat actors. To enhance the raw security logs, I developed a custom **PowerShell script** that performs Geolocation API lookups to map attacker origins in a custom Sentinel Workbook.

---

### 🏗️ Architecture & Tools
* **Cloud Infrastructure:** Microsoft Azure (Virtual Machines, Virtual Networks, Network Security Groups)
* **SIEM/Logging:** Microsoft Sentinel, Log Analytics Workspaces, Kusto Query Language (KQL)
* **Automation:** PowerShell (Event Log Parsing)
* **Network Security:** Traffic Analysis, RDP (3389) Monitoring, Firewall Configuration
* **Threat Intel:** IPGeolocation.io API

---

### Implementation Phases

---

#### 1. Honeypot Creation & Deployment

Once on the Azure home dashboard, lets first create our cloud based honeypot VM.

<img width="1693" height="847" alt="Screenshot 2026-03-15 224347" src="https://github.com/user-attachments/assets/3233e55d-47fc-471e-b2b8-27f382f1e48e" />
<br><br/>
<img width="1814" height="1048" alt="Screenshot 2026-03-15 224401" src="https://github.com/user-attachments/assets/0f369416-50a4-4488-b243-08d200051c4e" />
<br><br/>

Since The Standard_B1s VM size is being retired and is now only available in limited quantities across Azure regions, I've selected to run Windows 10 Enterprise version 22H2 x64 Gen2 which is still free services eligable.

<img width="948" height="1220" alt="Screenshot 2026-03-15 233013" src="https://github.com/user-attachments/assets/d5bc0a24-67fb-46e2-8f1b-1d94d8a9d11f" />
<br><br/>

Next, Create a username and a strong password with capital letters, lower case letters, numbers, and special characters. Allow RDP inbound so attackers can attempt to access the machine with a remote connection and so we can connect to it ourselves.

<img width="814" height="841" alt="Screenshot 2026-03-15 233055" src="https://github.com/user-attachments/assets/a6644092-a000-43fb-a5a8-00db6e290000" />
<br><br/>

We can skip the disk section as the default configurations are fine for our needs here. However, the networking is important as we need to modify our NSGs (Network Security Groups).

<img width="833" height="1018" alt="Screenshot 2026-03-15 233447" src="https://github.com/user-attachments/assets/4615db28-191f-4e8a-8537-c25ef579bc0d" />
<br><br/>

Delete the default groups as we need to create a NSG which allows ALL inbound connections through any port.

<img width="2546" height="402" alt="Screenshot 2026-03-15 233504" src="https://github.com/user-attachments/assets/c1653af3-95e3-4314-bdb3-5b44e09c4f39" />
<br><br/>

Add a new inbound rule and change the source and destination port ranges to an asterisk.

<img width="564" height="806" alt="Screenshot 2026-03-15 233552" src="https://github.com/user-attachments/assets/6cec2d12-6c28-4017-97bd-88bc51889852" />

<br><br/>

We can then create our virtual machine to deploy it after it validates.

<img width="768" height="1140" alt="Screenshot 2026-03-15 234337" src="https://github.com/user-attachments/assets/d1416eca-bb7d-4ee6-ba8d-7dcc4de031b8" />
<br><br/>

While the virtual machine is being deployed, we can create our LAW (Log Analytics Workspace). Choose the same workgroup we created for our VM and create a name for the LAW.

<img width="767" height="1190" alt="Screenshot 2026-03-15 234539" src="https://github.com/user-attachments/assets/fc409fc4-f27d-459b-bbc6-6bfef1475990" />
<br><br/>

Next, we'll need to configure Azure Defender for data collection. Navigate to environment settings and go into the LAW we created earlier.

<img width="2552" height="1221" alt="Screenshot 2026-03-15 234932" src="https://github.com/user-attachments/assets/af6247ff-f21c-47b3-aa75-edd07db96154" />
<br><br/>

We'll need to enable the servers plan and click save.

<img width="2548" height="566" alt="Screenshot 2026-03-15 235326" src="https://github.com/user-attachments/assets/4ef59883-e984-4f83-aed3-a26f9601a185" />
<br><br/>

Once the plans are enabled, we can go to the data collection setting and enable all events and click save. This will allow information to be analysed in our LAW by having events and logs saved to it.

<img width="1215" height="568" alt="Screenshot 2026-03-15 235432" src="https://github.com/user-attachments/assets/e9d23bbf-eaf8-4a7e-8841-800b3062f76b" />
<br><br/>

Next, we can add a data collection rule to connect the VM to our LAW. We'll configure the data collection rule to send us Windows Log Events

<img width="2541" height="1026" alt="Screenshot 2026-03-15 235936" src="https://github.com/user-attachments/assets/abe96796-a04e-48ca-bd83-01d52b6e8478" />
<br><br/>

<img width="2541" height="619" alt="Screenshot 2026-03-16 000233" src="https://github.com/user-attachments/assets/49c7ce14-0254-4743-b6f6-812d9609c5d6" />
<br><br/>

Before we add any resources, we need to create our Microsoft Sentinel and add our LAW to it.

<img width="2547" height="1238" alt="Screenshot 2026-03-16 000709" src="https://github.com/user-attachments/assets/2c8f1aaa-9460-4cbf-ad4f-c69ea8f3122b" />
<br><br/>

Once created, add our LAW to it by clicking on the LAW and clicking Add.

<img width="2211" height="1187" alt="Screenshot 2026-03-16 001246" src="https://github.com/user-attachments/assets/c37f384e-7eaa-40de-86c5-c9943a421160" />
<br><br/>

We can now go back to our VM to see that it is currently running under the IP address 20.163.168.200.

<img width="2190" height="442" alt="Screenshot 2026-03-16 001858" src="https://github.com/user-attachments/assets/b0582bb3-f7cc-4f1b-bd24-068b7dfec780" />
<br><br/>

In Windows, start the Remote Desktop Connection app by searching for it if need be, and paste the public IP address of our VM so we can connect to it.

<img width="400" height="236" alt="Screenshot 2026-03-16 001953" src="https://github.com/user-attachments/assets/0fe3bfeb-e366-4126-ae0c-e75c39c8e8d2" />
<br><br/>

Make sure to select "More Option" and select "Use Different Account" and then enter in the credentials we created when creating our VM.

<img width="441" height="433" alt="Screenshot 2026-03-16 002010" src="https://github.com/user-attachments/assets/b403c7b6-4b12-4306-923e-1b20cc53ede1" />
<br><br/>

Once we get logged into our VM, we will need IP geolocation API key for the powershell script at https://app.ipgeolocation.io 

I created an account and got a free API key. IPGeoLocation only allows 1000 API requests per day. So only 1000 attempts from hackers will have the data collected and the others will remain as normal raw data from Windows Event Viewer without the hacker’s geo location.

There is a couple more things we'll need before we can start testing. First, we'll need the Event ID form a failed login attempt in the Windows Event Viewer. I purposefully entered in the password incorrectly before connecting to the VM to generate a log event. This Event ID will be used later in our powershell script. In this case, the Event ID we need is 4625 which shows a failed logon attempt.

<img width="432" height="605" alt="Screenshot 2026-03-16 002208" src="https://github.com/user-attachments/assets/59e4b9c1-6d8c-4c97-960e-c8354bae3223" />
<br><br/>

<img width="2555" height="1393" alt="Screenshot 2026-03-16 003947" src="https://github.com/user-attachments/assets/47bf27a7-ddf6-4b29-9fb3-7d5307870bde" />
<br><br/>

In the host machine, open up command prompt and try to ping our VM by entering ping (VM public ip) and then -t so it continues to ping until we stop it. You’ll notice that we are not getting any replies, so malicious parties cannot do so either due to Windows Defender preventing this.

<img width="1107" height="324" alt="Screenshot 2026-03-16 004421" src="https://github.com/user-attachments/assets/9f6bd484-4a07-462a-9857-fd0f87e415ea" />
<br><br/>

We can disable the Windows Firewall in our VM here. Click Windows Defender Firewall Properties and then set the firewall state to "Off" for both the Private and Public network. This will open up our IP address to the public.

<img width="1402" height="776" alt="Screenshot 2026-03-16 005137" src="https://github.com/user-attachments/assets/5ab0356c-a960-4977-b281-a20573b1a2f7" />
<br><br/>

We should now be able to ping our VM from our host machine/network.

<img width="1088" height="609" alt="Screenshot 2026-03-16 005341" src="https://github.com/user-attachments/assets/66f72d8b-ef2e-4b51-8c24-10362617231c" />

<br><br/>

* Provisioned an **Azure Windows VM** with intentionally weakened security posture.
* Modified **Network Security Groups (NSG)** to allow unrestricted inbound traffic on **Port 3389 (RDP)**.
* Disabled local host firewalls to allow ICMP echo requests and unhindered protocol traversal for observation.

---

#### 2. PowerShell Automation

I wrote a script that serves as the bridge between raw Windows Security Logs and our SIEM. The script should be named Check_Event_4625_API.ps1 in this GitHub repository. The API key has been redacted from the file as that is bad security practice when publishing code. 

The script is also written to generate example entries to the log file. If you'd like to use the script as intended fo real scenarios/examples, change the line $TestMode = $true to $TestMode = $false

Here is the link for this script:
[Check_Event_4625_API.ps1](https://github.com/jaredcoppola/Azure-Sentinel-Honeypot-Home-Lab/blob/main/Check_Event_4625_API.ps1)
<br><br/>

In our VM, open up PowerShell ISE and past the code from the Check_Event_4625_API.ps1. After running the script, you'll see some sample data being generated. The file path for the log file will be at "C:\programdata\failed_rdp.log"

<img width="1686" height="1199" alt="Screenshot 2026-03-16 022503" src="https://github.com/user-attachments/assets/760f1832-5414-455d-93e1-ecda7b2943b6" />
<br><br/>

<img width="1117" height="627" alt="Screenshot 2026-03-16 022639" src="https://github.com/user-attachments/assets/f52f05c4-9677-425c-99c3-b4f5e688532a" />
<br><br/>

We will use the samples as well as our login attempt to train our LAW to extract the correct information from our logs and plot onto a world map.

Copy all the text in this file, and create a new note in your host OS and save the file somewhere easily accessible.


* **Detection:** Monitors **Event ID 4625** (Failed Logon).
* **Enrichment:** Extracts the attacker's IP and calls the **IPGeolocation.io API** to retrieve City, Country, Latitude, and Longitude.
* **Output:** Generates a custom log file (`failed_rdp.log`) in a standardized CSV format (This will later be converted to a JSON file for ingestion).

---

#### 3. SIEM Configuration & KQL

Before we do anything to analyze our data, we need to create a Data Collection Endpoint (DCE). You must do this before creating the table.

In the Azure Portal, search for Monitor. On the left-hand menu, under the Settings section, select Data Collection Endpoints. Click + Create.

Crucial: Ensure the Region you select matches the region of your Log Analytics Workspace (e.g., East US).

I named my endpoint "honeypotendpoint" but you can name it whatever you prefer. Click Review + Create.

<img width="775" height="647" alt="Screenshot 2026-03-16 033122" src="https://github.com/user-attachments/assets/7db24394-8b17-491f-96a5-2cd467fc3b5e" />
<br><br/>

Next, navigate to the LAW and within the Tables settings, and click create. I'll name the table Event4625, we then need to create a data collection rule. We can use the data collection rule we created earlier.

<<img width="2547" height="855" alt="Screenshot 2026-03-16 033703" src="https://github.com/user-attachments/assets/9182ac5b-9e61-44bc-b9ad-24a6c271b1b0" />
<br><br/>

It will then ask you to add your data source as a JSON file. Unfortunately, Azure has recently removed the ability to upload log and CVS formatted files into Azure for custom logs. I created another script to convert the generated log file failed_rdp.log into a json file using Log_To_JSON_Converter.ps1 in the repository. After running the script, you'll see another file generated called failed_rdp.json in the C:\ProgramData directory.

Here is the link for this script:
[Log_To_JSON_Converter.ps1](https://github.com/jaredcoppola/Azure-Sentinel-Honeypot-Home-Lab/blob/main/Log_To_JSON_Converter.ps1)
<br><br/>

<img width="1070" height="468" alt="Screenshot 2026-03-16 185820" src="https://github.com/user-attachments/assets/a9f38309-d405-46bb-9f6d-993d32760632" />
<br><br/>

<img width="2554" height="696" alt="Screenshot 2026-03-17 001349" src="https://github.com/user-attachments/assets/db49e9f3-2603-4ab0-937c-1e9e742e9b49" />
<br><br/>

Once the JSON file is uploaded into Azure, Azure Log Analytics requires a specific column named TimeGenerated to index logs by time. Since the script produces a column named timestamp, we just need to tell Azure to map one to the other. To do that, open the Transformation Editor. <br><br/>

On line 2, input the KQL query: <br><br/>
| extend TimeGenerated = todatetime(timestamp) and click run.
<br><br/>

<img width="1900" height="873" alt="Screenshot 2026-03-16 190631" src="https://github.com/user-attachments/assets/7979907b-c606-4ce2-86b5-bea9e11fceb9" />
<br><br/>

After the KQL query has been ran we can then click create to create our custom log. This is where I spent the most of my time troubleshooting as the custom table was not injesting the data I was inputting without an error code. After hours of troubleshooting and research I learned that my original Log_To_JSON_Converter.ps1 was creating a multi-line JSON file with indents. After rewritting the script and exporting the table data on a single line and adding my endpoint to the DRC chain, the table updated correctly. I'll include a screenshot of what the old JSON file was exporting as below.

<img width="2166" height="1062" alt="Screenshot 2026-03-16 235852" src="https://github.com/user-attachments/assets/36107cf6-8f27-444f-ba64-c27222d396e3" />
<br><br/>

<img width="613" height="985" alt="Screenshot 2026-03-16 185833" src="https://github.com/user-attachments/assets/5bfb37c0-c544-469c-95a0-fe34d3280483" />
<br><br/>

You can confirm the table was created and injested the data successfully by going to the Logs tab in our LAW and switching to KQL Mode 

<img width="616" height="747" alt="Screenshot 2026-03-16 210438" src="https://github.com/user-attachments/assets/d3592fa1-cb5b-44f5-94b9-19d68b3521a7" />
<br><br/>

By using the query below, we can sort the raw data into Custom Fields and have all the data labelled as we need it for plotting this information onto our World Map. Be sure to indent the query correctly.

         Event4625_CL
         | extend Lat = todouble(latitude), 
                  Lon = todouble(longitude)
         | summarize FailureCount = count() by Lat, Lon, country, city, ip_address
         | render scatterchart with (kind=map)

We need to use todouble() because Azure's map renderer requires coordinates to be in a numeric format to calculate the X/Y position on the Mercator projection.

<img width="1228" height="991" alt="Screenshot 2026-03-17 004200" src="https://github.com/user-attachments/assets/c3b3e715-75b7-4b84-81e2-8464ed0636f9" />
<br><br/>

The next part of this write-up will include only real data I've gotten from leaving the script running and the VM running for a couple of hours. I parced and readded only the real data points and not samples. 

I did this using the following KQL query.

         let ExcludedIPs = dynamic(["45.141.84.10", "92.118.160.17", "185.156.74.65", "193.163.125.115", ""]); <br><br/>
         Event4625_CL <br><br/>
         | extend Lat = todouble(latitude), 
           Lon = todouble(longitude) 
         | where ip_address !in (ExcludedIPs) 
         | summarize FailureCount = count() by Lat, Lon, country, city, ip_address <br><br/>
         | render scatterchart with (kind=map) 


Lets now go into Sentinel to plot this information on a world map. Click into our LAW, then Workbooks, then New and then remove the preset workbook Elements.

<img width="2025" height="1205" alt="Screenshot 2026-03-17 024410" src="https://github.com/user-attachments/assets/b290d2e9-8906-4e08-aff4-1fdc0cdeeccd" />
<br><br/>

Now click on Add and then Add query. I used the same query as above. The map settings and configurations are listed in the screenshot below. I choose to use Country of Origin rather then Latitude and Longitude as I feel it looked more pleasent to the eyes. With more data points and a bit more refinement with the script I would probably use Latitude and Longitude instead.

<img width="2556" height="1198" alt="Screenshot 2026-03-17 025704" src="https://github.com/user-attachments/assets/80a0f1ed-e840-42eb-a1a1-bf22bb2baeac" />
<br><br/>

We can now save our workbook so we can easily access it later if need be.

---

After finishing the lab, I believe there were many things I could have improved on and made better. For instance, maybe rewriting the script to include the Target User Name from the event log would have had more data to pull from. I was also fairly new to Azure so a lot of the procresses and and workflows on how to configure in the cloud escaped me.
Additionally, maybe looking into how the Data Collection Rules and Endpoints work so I could have the log analysis be more automated from VM to the Cloud database/logs but I could only do so much on the free trial of Azure. Ths project didn't turn out as automatted as I had hoped but that could be due to learning.

<img width="1535" height="777" alt="Screenshot 2026-03-17 030416" src="https://github.com/user-attachments/assets/d7e0a1d1-349b-4ddb-8c91-68fb2db1b5a5" />
<br><br/>

The Azure Resource Group has since also been deleted so I don't get charged for credits. 

Thank you for reading through this post and making it this far! I hope you enjoyed this lab! If you have any suggestions or fixes for my scripts or things I could do better please make some commits and let me know! This was mainly for self learning and practice so I'm sure I can make improvements in my processes.

---

