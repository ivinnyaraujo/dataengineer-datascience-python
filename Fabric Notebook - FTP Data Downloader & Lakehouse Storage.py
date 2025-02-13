#!/usr/bin/env python
# coding: utf-8

# ## Fabric Notebook - FTP Data Downloader & Lakehouse Storage
# 
# New notebook

# # Reading FTP Files & Writing to a Lakehouse in Microsoft Fabric

# This notebook connects to a FTP server to download .csv files and store them in a Fabric Lakehouse.

# In[ ]:


# Import modules

from ftplib import FTP  # interacting with an FTP server
import re  # use regular expressions to match file names (e.g., .csv files)
import os  # handling file paths and directory operations (e.g., creating directories)
import base64  # encoding/decoding passwords


# **Encoding Password Step**
# 
# For testing purpose the password was encoded using <u>Base64 Encoding</u>. **For PROD environments, recommended using Azure Key Vault instead as a safer option**. 

# In[ ]:


# Encode password
password = "password"
encoded_password = base64.b64encode(password.encode()).decode()
print(encoded_password)  # Save this encoded value


# **FTP Connection Details**

# In[ ]:


# FTP connection details
ftp_url = 'FTP URL'  # FTP server URL
ftp_port = 21               # FTP port
username = 'Username' # FTP username
encoded_password = 'Encoded Password'  # base64-encoded password
password = base64.b64decode(encoded_password).decode()  # Decode the password
file_regex = r'.*\.csv'    # Regex to match files (e.g., all CSV files)
remote_directory = '/npfm/sys/'  # Remote directory path


# **Define Lakehouse Path**

# In[ ]:


lakehouse_path = '/lakehouse/default/Files/ftp_download_test' # Lakehouse file path


# In[ ]:


# Connect to FTP server
def connect_ftp():
    ftp = FTP()
    ftp.connect(ftp_url, ftp_port)
    ftp.login(username, password)
    ftp.cwd(remote_directory)
    return ftp


# 
# **Function to Download Files from FTP Server**
# 
# Defining the `download_files_from_ftp` function, which:
# 1. Lists all files in the remote FTP directory.
# 2. Iterates through each file and checks if it matches the regex pattern (e.g., .csv files).
# 3. Downloads matching files from the FTP server and saves them to the specified local directory.
# 4. Prints a confirmation message for each downloaded file.
# This function is reusable and focuses solely on the file download logic.

# In[ ]:


# Download files from FTP server
def download_files_from_ftp(ftp, file_regex, local_directory):
    # List all files in the current remote directory
    file_list = ftp.nlst()
    
    # Iterate through each file in the directory
    for file_name in file_list:
        # Check if the file name matches the regex pattern (e.g., .csv files)
        if re.match(file_regex, file_name):
            # Create the full local file path in the Lakehouse
            local_file_path = os.path.join(local_directory, file_name)
            
            # Open the local file in binary write mode and download the file from the FTP server
            with open(local_file_path, 'wb') as local_file:
                ftp.retrbinary(f'RETR {file_name}', local_file.write)
            
            # Print a confirmation message
            print(f"Downloaded {file_name} to {local_file_path}")


# **Main Function and Script Entry Point**
# 
# Defines the `main` function, which:
#  1. Connects to the FTP server.
#  2. Ensures the local directory in the Lakehouse exists (creates it if necessary).
#  3. Calls the `download_files_from_ftp` function to download files.
#  4. Closes the FTP connection after the download is complete.
#  
#  - The `if __name__ == "__main__":` block ensures the `main` function runs only when the script is executed directly.
#  This block orchestrates the overall workflow of the script.

# In[ ]:


# Main function
def main():
    # Connect to FTP server
    ftp = connect_ftp()
    
    # Ensure the local directory exists in the Lakehouse
    if not os.path.exists(lakehouse_path):
        os.makedirs(lakehouse_path)  # Create the directory if it doesn't exist
    
    # Download files from the FTP server to the Lakehouse
    download_files_from_ftp(ftp, file_regex, lakehouse_path)
    
    # Close the FTP connection
    ftp.quit()

# Entry point of the script
if __name__ == "__main__":
    main()

