using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Microsoft.Win32;

namespace HRequestConfig
{
    public partial class FormMain : Form
    {
        public FormMain()
        {
            InitializeComponent();
        }

        private void FormMain_Load(object sender, EventArgs e)
        {
            // Load information from registry
            this.FormMain_Numeric_WebServer_Port.Text = (string)Registry.GetValue("HKEY_CURRENT_USER\\Software\\00laboratories\\winamp_hrequest", "WebsitePort", "8080");
            this.FormMain_TextBox_WebServer_Password.Text = (string)Registry.GetValue("HKEY_CURRENT_USER\\Software\\00laboratories\\winamp_hrequest", "WebsitePassword", "password");
        }

        /// <summary>
        /// Called when user presses the Cancel Button
        /// </summary>
        private void FormMain_Button_Cancel_Click(object sender, EventArgs e)
        {
            // Quit Application
            this.Close();
        }

        /// <summary>
        /// Called when user presses the Save Button
        /// </summary>
        private void FormMain_Button_Save_Click(object sender, EventArgs e)
        {
            Registry.SetValue("HKEY_CURRENT_USER\\Software\\00laboratories\\winamp_hrequest", "WebsitePort", this.FormMain_Numeric_WebServer_Port.Value, RegistryValueKind.String);
            Registry.SetValue("HKEY_CURRENT_USER\\Software\\00laboratories\\winamp_hrequest", "WebsitePassword", this.FormMain_TextBox_WebServer_Password.Text, RegistryValueKind.String);
            // Quit Application
            this.Close();
        }
    }
}
