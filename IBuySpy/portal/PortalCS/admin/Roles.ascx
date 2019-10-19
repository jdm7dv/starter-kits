<%@ Control Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<%@ Import Namespace="ASPNetPortal" %>
<script language="C#" runat="server">

    int tabIndex = 0;
    int tabId = 0;

    //*******************************************************
    //
    // The Page_Load server event handler on this user control is used
    // to populate the current roles settings from the configuration system
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Verify that the current user has access to access this page
        if (PortalSecurity.IsInRoles("Admins") == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        if (Request.Params["tabid"] != null) {
            tabId = Int32.Parse(Request.Params["tabid"]);
        }
        if (Request.Params["tabindex"] != null) {
            tabIndex = Int32.Parse(Request.Params["tabindex"]);
        }

        // If this is the first visit to the page, bind the role data to the datalist
        if (Page.IsPostBack == false) {

			BindData();
        }
    }

    //*******************************************************
    //
    // The AddRole_Click server event handler is used to add
    // a new security role for this portal
    //
    //*******************************************************

    void AddRole_Click(Object Sender, EventArgs e) {

    	// Obtain PortalSettings from Current Context
		PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

        // Add a new role to the database
        AdminDB admin = new AdminDB();
        admin.AddRole(portalSettings.PortalId, "New Role");
        
        // set the edit item index to the last item
        rolesList.EditItemIndex = rolesList.Items.Count;

        // Rebind list
        BindData();
    }

    //*******************************************************
    //
    // The RolesList_ItemCommand server event handler on this page 
    // is used to handle the user editing and deleting roles
    // from the RolesList asp:datalist control
    //
    //*******************************************************

    void RolesList_ItemCommand(object sender, DataListCommandEventArgs e) {

        AdminDB admin = new AdminDB();
        int roleId = (int) rolesList.DataKeys[e.Item.ItemIndex];
       
        if (e.CommandName == "edit") {

            // Set editable list item index if "edit" button clicked next to the item
            rolesList.EditItemIndex = e.Item.ItemIndex;

            // Repopulate the datalist control
            BindData();
        }
        else if (e.CommandName == "apply") {

            // Apply changes
            String _roleName = ((TextBox) e.Item.FindControl("roleName")).Text;
            
            // update database
            admin.UpdateRole(roleId, _roleName);
            
            // Disable editable list item access
            rolesList.EditItemIndex = -1;

            // Repopulate the datalist control
            BindData();
        }
        else if (e.CommandName == "delete") {

            // update database
            admin.DeleteRole(roleId);

            // Ensure that item is not editable
            rolesList.EditItemIndex = -1;

            // Repopulate list
            BindData();
        }
        else if (e.CommandName == "members") {
        
            // Save role name changes first
            String _roleName = ((TextBox) e.Item.FindControl("roleName")).Text;
            admin.UpdateRole(roleId, _roleName);

            // redirect to edit page
            Response.Redirect("~/Admin/SecurityRoles.aspx?roleId=" + roleId + "&rolename=" + _roleName + "&tabindex=" + tabIndex + "&tabid=" + tabId);
        }        
    }
    
	//*******************************************************
    //
    // The BindData helper method is used to bind the list of 
    // security roles for this portal to an asp:datalist server control
    //
    //*******************************************************

    void BindData() {

    	// Obtain PortalSettings from Current Context
		PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];
		
		// Get the portal's roles from the database
        AdminDB admin = new AdminDB();
        
        rolesList.DataSource = admin.GetPortalRoles(portalSettings.PortalId);
        rolesList.DataBind();
    }
    
    
</script>
<portal:title runat="server" id="Title1" />
<table cellpadding="2" cellspacing="0" border="0">
    <tr valign="top">
        <td class="Normal" width="100">
            &nbsp;
        </td>
        <td>
            <asp:DataList id="rolesList" OnItemCommand="RolesList_ItemCommand" DataKeyField="RoleID" runat="server">
                <ItemTemplate>
                    <asp:ImageButton ImageUrl="~/images/edit.gif" CommandName="edit" AlternateText="Edit this item" runat="server" />
                    <asp:ImageButton ImageUrl="~/images/delete.gif" CommandName="delete" AlternateText="Delete this item" runat="server" />
                    &nbsp;&nbsp;
                    <asp:Label Text='<%# DataBinder.Eval(Container.DataItem, "RoleName") %>' cssclass="Normal" runat="server" />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:Textbox id="roleName" width="200" cssclass="NormalTextBox" Text='<%# DataBinder.Eval(Container.DataItem, "RoleName") %>' runat="server" />
                    &nbsp;
                    <asp:LinkButton Text="Apply" CommandName="apply" cssclass="CommandButton" runat="server" />
                    &nbsp;
                    <asp:LinkButton Text="Change Role Members" CommandName="members" cssclass="CommandButton" runat="server" />
                </EditItemTemplate>
            </asp:DataList>
        </td>
    </tr>
    <tr>
        <td>
            &nbsp;
        </td>
        <td>
            <asp:LinkButton cssclass="CommandButton" OnClick="AddRole_Click" Text="Add New Role" runat="server" />
        </td>
    </tr>
</table>
