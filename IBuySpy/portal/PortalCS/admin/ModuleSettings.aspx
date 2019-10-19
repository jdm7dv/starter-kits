<%@ Page %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="ASPNetPortal" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%--
    The ModuleSettings.aspx page is used to enable administrators to view/edit/update
    a portal module's settings (title, output cache properties, edit access)
--%>
<html>
    <script language="C#" runat="server">

    int moduleId = 0;
    int tabId = 0;

    //*******************************************************
    //
    // The Page_Load server event handler on this page is used
    // to populate the module settings on the page
    //
    //*******************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Verify that the current user has access to access this page
        if (PortalSecurity.IsInRoles("Admins") == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        // Determine Module to Edit
        if (Request.Params["mid"] != null) {
            moduleId = Int32.Parse(Request.Params["mid"]);
        }
        // Determine Tab to Edit
        if (Request.Params["tabid"] != null) {
            tabId = Int32.Parse(Request.Params["tabid"]);
        }

        if (Page.IsPostBack == false) {
            BindData();
        }
    }

    //*******************************************************
    //
    // The ApplyChanges_Click server event handler on this page is used
    // to save the module settings into the portal configuration system
    //
    //*******************************************************

    void ApplyChanges_Click(Object Sender, EventArgs e) {
    
        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) HttpContext.Current.Items["PortalSettings"];

        object value = GetModule();
        if (value != null) {
            
            ModuleSettings m = (ModuleSettings) value;
            
            // Construct Authorized User Roles String
            String editRoles = "";

            foreach(ListItem item in authEditRoles.Items) {

                if (item.Selected == true) {
                    editRoles = editRoles + item.Text + ";";
                }
            }
            
            // update module
            AdminDB admin = new AdminDB();
            admin.UpdateModule(moduleId, m.ModuleOrder, m.PaneName, moduleTitle.Text, Int32.Parse(cacheTime.Text), editRoles, showMobile.Checked);

            // Update Textbox Settings
            moduleTitle.Text = m.ModuleTitle;
            cacheTime.Text = m.CacheTime.ToString();

            // Populate checkbox list with all security roles for this portal
            // and "check" the ones already configured for this module
            SqlDataReader roles = admin.GetPortalRoles(portalSettings.PortalId);

            // Clear existing items in checkboxlist
            authEditRoles.Items.Clear();

            ListItem allItem = new ListItem();
            allItem.Text = "All Users";

            if (m.AuthorizedEditRoles.LastIndexOf("All Users") > -1) {
                allItem.Selected = true;
            }

            authEditRoles.Items.Add(allItem);

            while(roles.Read()) {

                ListItem item = new ListItem();
                item.Text = (String) roles["RoleName"];
                item.Value = roles["RoleID"].ToString();

                if ((m.AuthorizedEditRoles.LastIndexOf(item.Text)) > -1) {
                    item.Selected = true;
                }

                authEditRoles.Items.Add(item);
            }
        }

        // Navigate back to admin page
        Response.Redirect("TabLayout.aspx?tabid=" + tabId);
    }

    //*******************************************************
    //
    // The BindData helper method is used to populate a asp:datalist
    // server control with the current "edit access" permissions
    // set within the portal configuration system
    //
    //*******************************************************

    void BindData() {

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) HttpContext.Current.Items["PortalSettings"];

        object value = GetModule();
        if (value != null) {
            
            ModuleSettings m = (ModuleSettings) value;
            
            // Update Textbox Settings
            moduleTitle.Text = m.ModuleTitle;
            cacheTime.Text = m.CacheTime.ToString();
            showMobile.Checked = m.ShowMobile;

            // Populate checkbox list with all security roles for this portal
            // and "check" the ones already configured for this module
            AdminDB admin = new AdminDB();
            SqlDataReader roles = admin.GetPortalRoles(portalSettings.PortalId);

            // Clear existing items in checkboxlist
            authEditRoles.Items.Clear();

            ListItem allItem = new ListItem();
            allItem.Text = "All Users";

            if (m.AuthorizedEditRoles.LastIndexOf("All Users") > -1) {
                allItem.Selected = true;
            }

            authEditRoles.Items.Add(allItem);

            while(roles.Read()) {

                ListItem item = new ListItem();
                item.Text = (String) roles["RoleName"];
                item.Value = roles["RoleID"].ToString();

                if ((m.AuthorizedEditRoles.LastIndexOf(item.Text)) > -1) {
                    item.Selected = true;
                }

                authEditRoles.Items.Add(item);
            }
        }
    }

    ModuleSettings GetModule() {
    
        // Obtain PortalSettings for this tab
        PortalSettings portalSettings = (PortalSettings) HttpContext.Current.Items["PortalSettings"];

        // Obtain selected module data
        foreach (ModuleSettings _module in portalSettings.ActiveTab.Modules) {
            
            if (_module.ModuleId == moduleId)
                return _module;
        }
        return null;
    }
    
    </script>
    <head>
        <link rel="stylesheet" href='<%= Request.ApplicationPath + "/Portal.css" %>' type="text/css" />
    </head>
    <body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0" marginheight="0" marginwidth="0">
        <form runat="server">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr valign="top">
                    <td colspan="2">
                        <portal:Banner ShowTabs="false" runat="server" />
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
                                    <table cellpadding="2" cellspacing="1" border="0">
                                        <tr>
                                            <td colspan="4">
                                                <table width="100%" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td align="left" class="Head">
                                                            Module Settings
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <hr noshade size="1pt">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="100" class="SubHead">
                                                Module Name:
                                            </td>
                                            <td colspan="3">
                                                &nbsp;<asp:Textbox id="moduleTitle" width="300" cssclass="NormalTextBox" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead">
                                                Cache Timeout (seconds):
                                            </td>
                                            <td colspan="3">
                                                &nbsp;<asp:Textbox id="cacheTime" width="100" cssclass="NormalTextBox" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td colspan="3">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead">
                                                Roles that can edit content:
                                            </td>
                                            <td colspan="3">
                                                <asp:CheckBoxList id="authEditRoles" RepeatColumns="2" Font-Names="Verdana,Arial" Font-Size="8pt" width="300" cellpadding="0" cellspacing="0" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td colspan="3">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead" nowrap>
                                                Show to mobile users?:
                                            </td>
                                            <td colspan="3">
                                                <asp:Checkbox id="showMobile" Font-Names="Verdana,Arial" Font-Size="8pt" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="4">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="4">
                                                <asp:LinkButton class="CommandButton" Text="Apply Module Changes" onclick="ApplyChanges_Click" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
