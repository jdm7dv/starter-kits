<%@ Import Namespace="ASPNetPortal" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.IO" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Page Language="C#" %>

<HTML>
  <HEAD>
<script runat="server">

    int itemId = 0;
    int moduleId = 0;

    //****************************************************************
    //
    // The Page_Load event on this Page is used to obtain the ModuleId
    // and ItemId of the document to edit.
    //
    // It then uses the ASPNetPortal.DocumentDB() data component
    // to populate the page's edit controls with the document details.
    //
    //****************************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Determine ModuleId of Announcements Portal Module
        moduleId = Int32.Parse(Request.Params["Mid"]);

        // Verify that the current user has access to edit this module
        if (PortalSecurity.HasEditPermissions(moduleId) == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        // Determine ItemId of Document to Update
        if (Request.Params["ItemId"] != null) {
            itemId = Int32.Parse(Request.Params["ItemId"]);
        }

        // If the page is being requested the first time, determine if an
        // document itemId value is specified, and if so populate page
        // contents with the document details

        if (Page.IsPostBack == false) {

            if (itemId != 0) {

                // Obtain a single row of document information
                ASPNetPortal.DocumentDB documents = new ASPNetPortal.DocumentDB();
                SqlDataReader dr = documents.GetSingleDocument(itemId);
                
                // Load first row into Datareader
                dr.Read();

                NameField.Text = (String) dr["FileFriendlyName"];
                PathField.Text = (String) dr["FileNameUrl"];
                CategoryField.Text = (String) dr["Category"];
                CreatedBy.Text = (String) dr["CreatedByUser"];
                CreatedDate.Text = ((DateTime) dr["CreatedDate"]).ToShortDateString();
                
                dr.Close();
            }

            // Store URL Referrer to return to portal
            ViewState["UrlReferrer"] = Request.UrlReferrer.ToString();
        }
    }

    //****************************************************************
    //
    // The UpdateBtn_Click event handler on this Page is used to either
    // create or update an document.  It  uses the ASPNetPortal.DocumentDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void UpdateBtn_Click(Object sender, EventArgs e) {

        // Only Update if Input Data is Valid
        if (Page.IsValid == true) {

            // Create an instance of the Document DB component
            ASPNetPortal.DocumentDB documents = new ASPNetPortal.DocumentDB();

            // Determine whether a file was uploaded
            
            if ((storeInDatabase.Checked == true) && (FileUpload.PostedFile != null)) {

                // for web farm support
                int length = (int) FileUpload.PostedFile.InputStream.Length;
                String contentType = FileUpload.PostedFile.ContentType;
                byte[] content = new byte[length];

                FileUpload.PostedFile.InputStream.Read(content, 0, length);
        
                // Update the document within the Documents table
                documents.UpdateDocument( moduleId, itemId, Context.User.Identity.Name, NameField.Text, PathField.Text, CategoryField.Text, content, length, contentType );        
            }
            else {
            
                if ((Upload.Checked == true) && (FileUpload.PostedFile != null)) {
                
                    // Calculate virtualPath of the newly uploaded file
                    String virtualPath = "~/uploads/" + Path.GetFileName(FileUpload.PostedFile.FileName);

                    // Calculate physical path of the newly uploaded file
                    String phyiscalPath = Server.MapPath(virtualPath);

                    // Save file to uploads directory
                    FileUpload.PostedFile.SaveAs(phyiscalPath);

                    // Update PathFile with uploaded virtual file location
                    PathField.Text = virtualPath;
                }
                documents.UpdateDocument( moduleId, itemId, Context.User.Identity.Name, NameField.Text, PathField.Text, CategoryField.Text, new byte[0], 0, "" );
            }

            // Redirect back to the portal home page
            Response.Redirect((String) ViewState["UrlReferrer"]);
        }
    }
    
    //****************************************************************
    //
    // The DeleteBtn_Click event handler on this Page is used to delete an
    // a document.  It  uses the ASPNetPortal.DocumentsDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void DeleteBtn_Click(Object sender, EventArgs e) {

        // Only attempt to delete the item if it is an existing item
        // (new items will have "ItemId" of 0)

        if (itemId != 0) {

            ASPNetPortal.DocumentDB documents = new ASPNetPortal.DocumentDB();
            documents.DeleteDocument(itemId);
        }

        // Redirect back to the portal home page
        Response.Redirect((String) ViewState["UrlReferrer"]);
    }

    //****************************************************************
    //
    // The CancelBtn_Click event handler on this Page is used to cancel
    // out of the page, and return the user back to the portal home
    // page.
    //
    //****************************************************************

    void CancelBtn_Click(Object sender, EventArgs e) {

        // Redirect back to the portal home page
        Response.Redirect((String) ViewState["UrlReferrer"]);
    }

</script>
        <link rel="stylesheet" href='<%= Request.ApplicationPath + "/Portal.css" %>' type="text/css" >
  </HEAD>
    <body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0" marginheight="0" marginwidth="0">
        <form enctype="multipart/form-data" runat="server">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr valign="top">
                    <td colspan="2">
                        <portal:Banner id="SiteHeader" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <br>
                        <table width="98%" cellspacing="0" cellpadding="4" border="0">
                            <tr valign="top">
                                <td width="150">
                                    &nbsp;
                                </td>
                                <td>
                                    <table width="500" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="left" class="Head">
                                                Document Details
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <hr noshade size="1">
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="726" cellspacing="0" cellpadding="0" border="0">
                                        <tr valign="top">
                                            <td width="100" class="SubHead">
                                                Name:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox id="NameField" cssclass="NormalTextBox" width="353" Columns="28" maxlength="150" runat="server" />
                                            </td>
                                            <td width="25" rowspan="6">
                                                &nbsp;
                                            </td>
                                            <td class="Normal" width="250">
                                                <asp:RequiredFieldValidator Display="Static" runat="server" ErrorMessage="You Must Enter a Valid Name" ControlToValidate="NameField" id=RequiredFieldValidator1 />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Category:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox id="CategoryField" cssclass="NormalTextBox" width="353" Columns="28" maxlength="50" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td colspan="2">
                                                <hr noshade size="1" width="100%">
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td width="100" class="SubHead">
                                                URL to Browse:
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <asp:textbox id="PathField" cssclass="NormalTextBox" width="353" Columns="28" maxlength="250" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead">
                                                — or —
                                            </td>
                                            <td colspan="2">
                                                &nbsp;
                                                <br>
                                                <br>
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td nowrap class="SubHead">
                                                Upload to Web Server:&nbsp;
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <asp:CheckBox id="Upload" Cssclass="Normal" Text="Upload document to server" runat="server" />
                                                <br>
                                                <asp:CheckBox id="storeInDatabase" Cssclass="Normal" Text="Store in database (web farm support)" runat="server" />
                                                <br>
                                                <input type="file" id="FileUpload" width="300" style="WIDTH:353px;FONT-FAMILY:verdana" runat="server" >
                                            </td>
                                        </tr>
                                    </table>
                                    <p>
                                        <asp:LinkButton id="updateButton" Text="Update" runat="server" class="CommandButton" BorderStyle="none" OnClick="UpdateBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="cancelButton" Text="Cancel" CausesValidation="False" runat="server" class="CommandButton" BorderStyle="none" OnClick="CancelBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="deleteButton" Text="Delete this item" CausesValidation="False" runat="server" class="CommandButton" BorderStyle="none" OnClick="DeleteBtn_Click" />
                                        <hr noshade size="1" width="500">
                                        <span class="Normal">Created by
                                            <asp:label id="CreatedBy" runat="server" />
                                            on
                                            <asp:label id="CreatedDate" runat="server" />
                                            <br>
                                        </span>
            <P></P>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</HTML>
