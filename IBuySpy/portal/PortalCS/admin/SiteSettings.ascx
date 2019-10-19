<%@ Control Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<%@ Import Namespace="ASPNetPortal" %>
<script language="C#" runat="server">

    //*******************************************************
    //
    // The Page_Load server event handler on this user control is used
    // to populate the current site settings from the config system
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Verify that the current user has access to access this page
        if (PortalSecurity.IsInRoles("Admins") == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        // If this is the first visit to the page, populate the site data
        if (Page.IsPostBack == false) {

            // Obtain PortalSettings from Current Context
            PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

            siteName.Text = portalSettings.PortalName;
            showEdit.Checked = portalSettings.AlwaysShowEditButton;
        }
    }

    //*******************************************************
    //
    // The Apply_Click server event handler is used
    // to update the Site Name within the Portal Config System
    //
    //*******************************************************

    void Apply_Click(Object sender, EventArgs e) {

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

        // update Tab info in the database
        AdminDB admin = new AdminDB();
        admin.UpdatePortalInfo(portalSettings.PortalId, siteName.Text, showEdit.Checked);

        // Redirect to this site to refresh
        Response.Redirect(Request.RawUrl);
    }

</script>
<portal:title runat="server" />
<table cellpadding="2" cellspacing="0" border="0">
    <tr>
        <td width="100" class="Normal">
            Site Title:
        </td>
        <td colspan="2" class="NormalTextBox">
            <asp:Textbox id="siteName" width="240" runat="server" />
        </td>
    </tr>
    <tr>
        <td class="Normal">
            Always show edit button?:
        </td>
        <td colspan="2" class="Normal">
            <asp:CheckBox id="showEdit" runat="server" />
        </td>
    </tr>
    <tr>
        <td>
            &nbsp;
        </td>
        <td colspan="2">
            <asp:LinkButton id="applyBtn" class="CommandButton" Text="Apply Changes" onclick="Apply_Click" runat="server" />
        </td>
    </tr>
</table>
