<%@ Import Namespace="ASPNetPortal" %>

<%--

   The PortalModuleTitle User Control is responsible for displaying the title of each
   portal module within the portal -- as well as optionally the module's "Edit Page"
   (if such a page has been configured).

--%>

<script language="C#" runat="server">

    public String EditText = null;
    public String EditUrl  = null;
    public String EditTarget = null;

    void Page_Load(Object sender, EventArgs e) {

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) HttpContext.Current.Items["PortalSettings"];

        // Obtain reference to parent portal module
        PortalModuleControl portalModule = (PortalModuleControl) this.Parent;

        // Display Modular Title Text and Edit Buttons
        ModuleTitle.Text = portalModule.ModuleConfiguration.ModuleTitle;

        // Display the Edit button if the parent portalmodule has configured the PortalModuleTitle User Control
        // to display it -- and the current client has edit access permissions
        if ((portalSettings.AlwaysShowEditButton == true) || (PortalSecurity.IsInRoles(portalModule.ModuleConfiguration.AuthorizedEditRoles)) && (EditText != null)) {

            EditButton.Text = EditText;
            EditButton.NavigateUrl = EditUrl + "?mid=" + portalModule.ModuleId.ToString();
            EditButton.Target = EditTarget;
        }
    }

</script>

<table width="98%" cellspacing="0" cellpadding="0">
    <tr>
        <td align="left">
            <asp:label id="ModuleTitle" cssclass="Head" EnableViewState="false" runat="server" />
        </td>
        <td align="right">
            <asp:hyperlink id="EditButton" cssclass="CommandButton" EnableViewState="false" runat="server" />
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <hr noshade size="1pt">
        </td>
    </tr>
</table>
