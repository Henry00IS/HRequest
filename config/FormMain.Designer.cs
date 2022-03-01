namespace HRequestConfig
{
    partial class FormMain
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormMain));
            this.FormMain_GroupBox_WebServer = new System.Windows.Forms.GroupBox();
            this.FormMain_Label_WebServer_Port = new System.Windows.Forms.Label();
            this.FormMain_Label_WebServer_Password = new System.Windows.Forms.Label();
            this.FormMain_Numeric_WebServer_Port = new System.Windows.Forms.NumericUpDown();
            this.FormMain_TextBox_WebServer_Password = new System.Windows.Forms.TextBox();
            this.FormMain_Button_Cancel = new System.Windows.Forms.Button();
            this.FormMain_Button_Save = new System.Windows.Forms.Button();
            this.FormMain_GroupBox_WebServer.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.FormMain_Numeric_WebServer_Port)).BeginInit();
            this.SuspendLayout();
            // 
            // FormMain_GroupBox_WebServer
            // 
            this.FormMain_GroupBox_WebServer.Controls.Add(this.FormMain_TextBox_WebServer_Password);
            this.FormMain_GroupBox_WebServer.Controls.Add(this.FormMain_Numeric_WebServer_Port);
            this.FormMain_GroupBox_WebServer.Controls.Add(this.FormMain_Label_WebServer_Password);
            this.FormMain_GroupBox_WebServer.Controls.Add(this.FormMain_Label_WebServer_Port);
            this.FormMain_GroupBox_WebServer.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormMain_GroupBox_WebServer.Location = new System.Drawing.Point(12, 12);
            this.FormMain_GroupBox_WebServer.Name = "FormMain_GroupBox_WebServer";
            this.FormMain_GroupBox_WebServer.Size = new System.Drawing.Size(255, 92);
            this.FormMain_GroupBox_WebServer.TabIndex = 0;
            this.FormMain_GroupBox_WebServer.TabStop = false;
            this.FormMain_GroupBox_WebServer.Text = "WebServer Settings";
            // 
            // FormMain_Label_WebServer_Port
            // 
            this.FormMain_Label_WebServer_Port.AutoSize = true;
            this.FormMain_Label_WebServer_Port.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormMain_Label_WebServer_Port.Location = new System.Drawing.Point(14, 24);
            this.FormMain_Label_WebServer_Port.Name = "FormMain_Label_WebServer_Port";
            this.FormMain_Label_WebServer_Port.Size = new System.Drawing.Size(41, 16);
            this.FormMain_Label_WebServer_Port.TabIndex = 0;
            this.FormMain_Label_WebServer_Port.Text = "Port:";
            // 
            // FormMain_Label_WebServer_Password
            // 
            this.FormMain_Label_WebServer_Password.AutoSize = true;
            this.FormMain_Label_WebServer_Password.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormMain_Label_WebServer_Password.Location = new System.Drawing.Point(14, 54);
            this.FormMain_Label_WebServer_Password.Name = "FormMain_Label_WebServer_Password";
            this.FormMain_Label_WebServer_Password.Size = new System.Drawing.Size(76, 16);
            this.FormMain_Label_WebServer_Password.TabIndex = 1;
            this.FormMain_Label_WebServer_Password.Text = "Password:";
            // 
            // FormMain_Numeric_WebServer_Port
            // 
            this.FormMain_Numeric_WebServer_Port.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormMain_Numeric_WebServer_Port.Location = new System.Drawing.Point(96, 22);
            this.FormMain_Numeric_WebServer_Port.Maximum = new decimal(new int[] {
            65535,
            0,
            0,
            0});
            this.FormMain_Numeric_WebServer_Port.Name = "FormMain_Numeric_WebServer_Port";
            this.FormMain_Numeric_WebServer_Port.Size = new System.Drawing.Size(70, 23);
            this.FormMain_Numeric_WebServer_Port.TabIndex = 2;
            // 
            // FormMain_TextBox_WebServer_Password
            // 
            this.FormMain_TextBox_WebServer_Password.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormMain_TextBox_WebServer_Password.Location = new System.Drawing.Point(96, 51);
            this.FormMain_TextBox_WebServer_Password.Name = "FormMain_TextBox_WebServer_Password";
            this.FormMain_TextBox_WebServer_Password.Size = new System.Drawing.Size(140, 23);
            this.FormMain_TextBox_WebServer_Password.TabIndex = 3;
            // 
            // FormMain_Button_Cancel
            // 
            this.FormMain_Button_Cancel.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormMain_Button_Cancel.Location = new System.Drawing.Point(12, 118);
            this.FormMain_Button_Cancel.Name = "FormMain_Button_Cancel";
            this.FormMain_Button_Cancel.Size = new System.Drawing.Size(78, 38);
            this.FormMain_Button_Cancel.TabIndex = 1;
            this.FormMain_Button_Cancel.Text = "Cancel";
            this.FormMain_Button_Cancel.UseVisualStyleBackColor = true;
            this.FormMain_Button_Cancel.Click += new System.EventHandler(this.FormMain_Button_Cancel_Click);
            // 
            // FormMain_Button_Save
            // 
            this.FormMain_Button_Save.Font = new System.Drawing.Font("Verdana", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.FormMain_Button_Save.Location = new System.Drawing.Point(189, 118);
            this.FormMain_Button_Save.Name = "FormMain_Button_Save";
            this.FormMain_Button_Save.Size = new System.Drawing.Size(78, 38);
            this.FormMain_Button_Save.TabIndex = 2;
            this.FormMain_Button_Save.Text = "Save";
            this.FormMain_Button_Save.UseVisualStyleBackColor = true;
            this.FormMain_Button_Save.Click += new System.EventHandler(this.FormMain_Button_Save_Click);
            // 
            // FormMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.LightSteelBlue;
            this.ClientSize = new System.Drawing.Size(278, 168);
            this.Controls.Add(this.FormMain_Button_Save);
            this.Controls.Add(this.FormMain_Button_Cancel);
            this.Controls.Add(this.FormMain_GroupBox_WebServer);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FormMain";
            this.Text = "Winamp HRequest System";
            this.Load += new System.EventHandler(this.FormMain_Load);
            this.FormMain_GroupBox_WebServer.ResumeLayout(false);
            this.FormMain_GroupBox_WebServer.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.FormMain_Numeric_WebServer_Port)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox FormMain_GroupBox_WebServer;
        private System.Windows.Forms.TextBox FormMain_TextBox_WebServer_Password;
        private System.Windows.Forms.NumericUpDown FormMain_Numeric_WebServer_Port;
        private System.Windows.Forms.Label FormMain_Label_WebServer_Password;
        private System.Windows.Forms.Label FormMain_Label_WebServer_Port;
        private System.Windows.Forms.Button FormMain_Button_Cancel;
        private System.Windows.Forms.Button FormMain_Button_Save;

    }
}

