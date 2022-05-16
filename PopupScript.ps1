Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# Locations
$LogLocation = $env:LogLocation
$IconLocation = (Join-Path $LogLocation "\icon.ico")
$LogFile = (Join-Path $LogLocation "\PopupLog.csv")

$UserName = $env:USERNAME
$Width = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
$Height = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height

# Check if user already accepted agreement and don't show form
# if (Select-String -Path $LogFile -Pattern $UserName -Quiet) {
#     exit
# }

# Creates logfile if it doesn't exists and adds headers
if (-not(Test-Path -Path $LogFile -PathType Leaf)) {
    New-Item -ItemType File -Path $LogFile -Force -ErrorAction Stop
    "sep=;" | out-file -filepath $LogFile -append # To make sure Excel opens correctly
    "Date;EDIPI" | out-file -filepath $LogFile -append
    Write-Host "The file [$LogFile] has been created."
}

# Accept Button
$Accept =
{
    # Checking if user is already in log, so there's not duplicates
    if (Select-String -Path $LogFile -Pattern $UserName -Quiet) { $AUPForm.Close() }
    # Adds user to logfile
    else {
        (Get-Date -UFormat "%Y-%m-%d-%H:%M") + ";" + $UserName | out-file -filepath $LogFile -append
    }
}

# Cancel Button
$Cancel = 
{
    # Logs off if user doesn't accept agreement
    $AUPForm.Close()
    shutdown /l /f
}

# Form Layout
$AUPForm = New-Object system.Windows.Forms.Form -Property @{TopMost = $true }
$AUPForm.ClientSize = "$Width ,$Height"
$AUPForm.text = "CANNON AIR FORCE BASE (CAFB) Rules of Behavior and Acceptable Use Standards for Air Force Information Technology"
$AUPForm.BackColor = "#ffffff"
$AUPForm.Icon = New-Object system.drawing.icon ($IconLocation)
$AUPForm.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 12)
$AUPForm.MaximizeBox = $False
$AUPForm.MinimizeBox = $False
$AUPForm.FormBorderStyle = 'None'

# If user tries to close by ALT+F4 or Task Manager without accepting agreement, they will be logged out
$AUPForm.Add_Closing({ param($CloseSender, $DefaultEvent)
        if (-not([System.Diagnostics.StackTrace]::new().GetFrames().GetMethod().Name -ccontains 'Close')) {
            $result = [System.Windows.Forms.MessageBox]::Show(`
                    "Are you sure you want to exit?`nYou will be logged off if you don't agree.", `
                    "Close", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel)
            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) { $DefaultEvent.Cancel = $true } else { shutdown /l /f }
        }
    })

$AcceptButton = New-Object system.Windows.Forms.Button
$AcceptButton.text = "I Accept These Terms"
$AcceptButton.BackColor = "#00FF00"
$AcceptButton.width = 160
$AcceptButton.height = 80
$AcceptButton.location = New-Object System.Drawing.Point((($Width * 0.33) - $AcceptButton.width / 2), (($Height * 0.9) - ($AcceptButton.height / 4)))
$AcceptButton.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$AcceptButton.add_Click($Accept)

$CancelButton = New-Object system.Windows.Forms.Button
$CancelButton.text = "I Decline These Terms, Log Off!"
$CancelButton.BackColor = "#FF0000"
$CancelButton.width = 160
$CancelButton.height = 80
$CancelButton.location = New-Object System.Drawing.Point((($Width * 0.66) - $AcceptButton.width / 2), (($Height * 0.9) - ($AcceptButton.height / 4)))
$CancelButton.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
$CancelButton.add_Click($Cancel)

$AUPInfo = New-Object System.Windows.Forms.TextBox
$AUPInfo.Text = "The following statements reflect mandatory behavioral norms and standards of acceptable use of Air Force Information Technology in accordance with Air Force Manual 17-1301, Computer Security. By signing below, you indicate both your understanding of these standards, and your agreement to act in accordance with them as a condition of your service with or access within the Air Force. Air Force Instruction 17-130, Cybersecurity Program Management, applies.

1. I WILL adhere to and actively support all legal, regulatory, and command requirements.
`ta. I understand that Air Force Information Technology is to be used primarily for Official/ Government Business, and that limited personal use must be of reasonable duration and frequency that have been approved by the supervisors and do not adversely affect performance of official duties, overburden systems or reflect adversely on the Air Force or the DoD.
`tb. I will not use my access to government information or resources for private gain.
`tc. I waive my expectation of privacy in my Air Force electronic communications. This is not a waiver of my rights to attorney-client privilege, medical information privacy, or the privacy afforded communications with religious officials/chaplains.
`td. I will observe all software license agreements and Federal copyright laws.
`te. I will promptly report all security incidents in accordance with Air Force policy.

2. I WILL use the system in a manner that protects information confidentiality, integrity and/or availability.
`ta. I will not store or process classified information on any system not approved for classified processing.
`tb. I will protect my Common Access Card/hardware token from loss, compromise, or premature destruction. I will not share my token/credentials with anyone, use another person's token/credentials, or use a computer or terminal on behalf of another person.
`tc. I will protect my passwords/Personal Identification Numbers from disclosure: I will not post or write these down in my workspace.
`td. I will lock or log-off my computer or terminal any time I walk away.
`te. I understand that my password/Personal Identification Numbers must adhere to current Air Force standards for length, key-space, and aging requirements.
`tf. I will not disclose any non-public Air Force or DoD information to unauthorized individuals.
`tg. I understand that everything done using my Common Access Card/hardware token/password/Personal Identification Number will be regarded as having been done by me.
`th. I will employ anti-malware software and update it as required; I will immediately notify my CFP or WCO if I believe Air Force Information Technology assets entrusted to me have been compromised; I will take immediate measures to limit damage.

3. I WILL protect the physical integrity of computing resources entrusted to my custody or use.
`ta. I will protect Air Force Information Technology from hazards such as liquids, food, smoke, staples, paper clips, etc.
`tb. I will protect Air Force Information Technology from tampering, theft, or loss; I will take particular care to protect any portable devices and media entrusted to me, such as laptops, cell phones, tablets, disks, and other portable electronic storage media.
`tc. I will protect Air Force Information Technology storage media from exposure to physical, electrical, and environmental hazards. I will ensure that media is secured when not in use based on the sensitivity of the information contained, and practice proper labeling procedures.
`td. I will not allow anyone to enter DoD or Air Force facilities without proper authorization.
`te. I will not install, relocate, modify, or remove any Air Force Information Technology without proper approval.

4. I WILL NOT attempt to exceed my authorized privileges.
`ta. I will not access, research, or change any account, file, record, or application not required to perform my job.
`tb. I will not modify the operating system configuration on Air Force Information Technology without proper approval.
`tc. I will not move equipment, add, or exchange system components without authorization by the appropriate approval of my local systems manager or local Information Technology Equipment Custodian (ITEC) personnel.
`td. I will not use, or connect to, non-official hardware, software, or networks for official business without proper approval and without the use of authorized mobile device network encryption.

5. I WILL NOT use systems in a way that brings discredit on Air Force users or the Air Force or degrade Air Force missions.
`ta. I will practice operational security in accordance with guidance contained in Air Force Instruction 10-701,Operations Security.
`tb. I will not receive or send inappropriate material using my official email or Internet accounts.
`tc. I will not originate or forward chain letters, hoaxes, or items that advocate or support a political, moral, or philosophical agenda.
`td. I will not add slogans, quotes, or other personalization to an official signature block.
`te. I understand that pornography, sexually explicit or sexually oriented material, nudity, hate speech or ridicule of others on the bases of protected class (e.g., race, creed, religion, color, age, sex, disability, national origin), gambling, illegal weapons, militant, extremist, or terrorist activities will not be tolerated.
`tf. I will not connect or remove any form of removable media without proper approval.

6. I WILL NOT waste system and network resources.
`ta. I will not make excessive use of my official computer to engage with social media for personal purposes (e.g., Facebook, Twitter, Instagram, Snapchat, etc.)
`tb. I will not make excessive use of my official computer for shopping, or to view full-motion video from non- official sources (e.g., YouTube, online multiplayer video games, etc.)
`tc. I will not auto forward e-mail from my official account to a personal e-mail account."

$AUPInfo.Multiline = $True;
$AUPInfo.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 14)
$AUPInfo.WordWrap = $True
$AUPInfo.Location = New-Object System.Drawing.Size(($Width * 0.05), ($Height * 0.05))
$AUPInfo.Size = New-Object System.Drawing.Size(($Width * 0.9), ($Height * 0.8))
$AUPInfo.Scrollbars = "Vertical"

$AUPForm.controls.AddRange(@($AcceptButton, $CancelButton, $AUPInfo))

# Run
[void]$AUPForm.ShowDialog()