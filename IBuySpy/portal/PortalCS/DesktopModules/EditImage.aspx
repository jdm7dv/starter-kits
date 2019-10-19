<%@ Page Language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="ASPNetPortal" %>
<script runat="server">

    int moduleId = 0;

    //****************************************************************
    //
    // The Page_Load event on this Page is used to obtain the ModuleId
    // of the image module to edit.
    //
    // It then uses the ASP.NET configuration system to populate the page's
    // edit controls with the image details.
    //
    //****************************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Determine ModuleId of Announcements Portal Module
        moduleId = Int32.Parse(Request.Params["Mid"]);

        // Verify that the current user has access to edit this module
        if (PortalSecurity.HasEditPermissions(moduleId) == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        if (Page.IsPostBack == false) {

            if (moduleId > 0) {
            
                Hashtable settings;
                
                // Get settings from the database
                settings = PortalSettings.GetModuleSettings(moduleId);
                
                Src.Text = (String) settings["src"];
                Width.Text = (String) settings["width"];
                Height.Text = (String) settings["height"];
            }
            
            // Store URL Referrer to return to portal
            ViewState["UrlReferrer"] = Request.UrlReferrer.ToString();
        }
    }

    //****************************************************************
    //
    // The UpdateBtn_Click event handler on this Page is used to save
    // the settings to the ModuleSettings database table.  It  uses the 
    // ASPNetPortal.AdminDB() data component to encapsulate the data 
    // access functionality.
    //
    //****************************************************************

    void UpdateBtn_Click(Object sender, EventArgs e) {

        // Update settings in the database
        AdminDB admin = new AdminDB();
        
        admin.UpdateModuleSetting(moduleId, "src", Src.Text);
        admin.UpdateModuleSetting(moduleId, "height", Height.Text);
        admin.UpdateModuleSetting(moduleId, "width", Width.Text);

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
<html>
    <head>
        <link rel="stylesheet" href='<%= Request.ApplicationPath + "/Portal.css" %>' type="text/css" />
    </head>
    <body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0" marginheight="0" marginwidth="0">
        <form runat="server">
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
                                <td width="*">
                                    <table width="500" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="left" class="Head">
                                                Image Settings
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="500" cellspacing="0" cellpadding="0">
                                        <tr valign="top">
                                            <td width="100" class="SubHead">
                                                Src Location:
                                            </td>
                                            <td rowspan="3">
                                                &nbsp;
                                            </td>
                                            <td class="Normal">
                                                <asp:TextBox id="Src" cssclass="NormalTextBox" width="390" Columns="30" runat="server" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Image Width:
                                            </td>
                                            <td>
                                                <asp:TextBox id="Width" cssclass="NormalTextBox" width="390" Columns="30" runat="server" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="SubHead">
                                                Image Height:
                                            </td>
                                            <td>
                                                <asp:TextBox id="Height" cssclass="NormalTextBox" width="390" Columns="30" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                    <p>
                                        <asp:LinkButton id="updateButton" Text="Update" runat="server" class="CommandButton" BorderStyle="none" OnClick="UpdateBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="cancelButton" Text="Cancel" CausesValidation="False" runat="server" class="CommandButton" BorderStyle="none" OnClick="CancelBtn_Click" />
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
