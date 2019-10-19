<%@ Page language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="ASPNetPortal" %>
<%--
    The SecurityRoles.aspx page is used to create and edit security roles within
    the Portal application.
--%>
<script runat="server">

    int    roleId   = -1;
    String roleName = "";
    int    tabIndex = 0;
    int    tabId = 0;

    //*******************************************************
    //
    // The Page_Load server event handler on this page is used
    // to populate the role information for the page
    //
    //*******************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Verify that the current user has access to access this page
        if (PortalSecurity.IsInRoles("Admins") == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        // Calculate security roleId
        if (Request.Params["roleid"] != null) {
            roleId = Int32.Parse(Request.Params["roleid"]);
        }
        if (Request.Params["rolename"] != null) {
            roleName = (String)Request.Params["rolename"];
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
    // The Save_Click server event handler on this page is used
    // to save the current security settings to the configuration system
    //
    //*******************************************************

    void Save_Click(Object Sender, EventArgs e) {

    	// Obtain PortalSettings from Current Context
		PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

        // Navigate back to admin page
        Response.Redirect("~/DesktopDefault.aspx?tabindex=" + tabIndex + "&tabid=" + tabId);
    }

    //*******************************************************
    //
    // The AddUser_Click server event handler is used to add
    // a new user to this security role 
    //
    //*******************************************************

    void AddUser_Click(Object sender, EventArgs e) {

        int userId;
        
        if (((LinkButton)sender).ID == "addNew") {
        
            // add new user to users table
            UsersDB users = new UsersDB();
            if ((userId = users.AddUser(windowsUserName.Text, windowsUserName.Text, "acme")) == -1) {

                Message.Text = "Add New Failed!  There is already an entry for <" + "u" + ">" + windowsUserName.Text + "<" + "/u" + "> in the Users database." + "<" + "br" + ">" + "Please use Add Existing for this user.";
            }
        }
        else {
        
            //get user id from dropdownlist of existing users
            userId = Int32.Parse(allUsers.SelectedItem.Value);
        }
              
        if (userId != -1) {
            // Add a new userRole to the database
            AdminDB admin = new AdminDB();
            admin.AddUserRole(roleId, userId);
        }
        
        // Rebind list
        BindData();
    }

    //*******************************************************
    //
    // The usersInRole_ItemCommand server event handler on this page 
    // is used to handle the user editing and deleting roles
    // from the usersInRole asp:datalist control
    //
    //*******************************************************

    void usersInRole_ItemCommand(object sender, DataListCommandEventArgs e) {

        AdminDB admin = new AdminDB();
        int userId = (int) usersInRole.DataKeys[e.Item.ItemIndex];
       
        if (e.CommandName == "delete") {

            // update database
            admin.DeleteUserRole(roleId, userId);

            // Ensure that item is not editable
            usersInRole.EditItemIndex = -1;

            // Repopulate list
            BindData();
        }
    }
    
	//*******************************************************
    //
    // The BindData helper method is used to bind the list of 
    // security roles for this portal to an asp:datalist server control
    //
    //*******************************************************

    void BindData() {
    
        // unhide the Windows Authentication UI, if application
        if (User.Identity.AuthenticationType != "Forms") {
        
            windowsUserName.Visible = true;
            addNew.Visible = true;
        }

		// add the role name to the title
		if (roleName != "") {
		
			title.InnerText = "Role Membership: " + roleName;
		}
		
		// Get the portal's roles from the database
        AdminDB admin = new AdminDB();
        
        // bind users in role to DataList
        usersInRole.DataSource = admin.GetRoleMembers(roleId);
        usersInRole.DataBind();

        // bind all portal users to dropdownlist
        allUsers.DataSource = admin.GetUsers();
        allUsers.DataBind();
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
                        <portal:Banner ShowTabs="false" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <br>
                        <table width="98%" cellspacing="0" cellpadding="4" border="0">
                            <tr height="*" valign="top">
                                <td width="100">
                                    &nbsp;
                                </td>
                                <td width="*">
                                    <table width="450" cellpadding="2" cellspacing="4" border="0">
                                        <tr>
                                            <td colspan="2">
                                                <table width="100%" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td align="left">
                                                            <span id="title" class="Head" runat="server">Role Membership</span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <hr noshade size="1pt">
                                                        </td>
                                                    </tr>
                                                </table>
                                                <asp:Label id="Message" CssClass="NormalRed" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <table width="100%" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td>
                                                            <asp:TextBox id="windowsUserName" Text="DOMAIN\username" Visible="False" runat="server" />
                                                        </td>
                                                        <td class="Normal">
                                                            <asp:LinkButton id="addNew" cssclass="CommandButton" OnClick="AddUser_Click" Text="Create new user and add to role" Visible="False" runat="server" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:DropDownList id="allUsers" DataTextField="Email" DataValueField="UserID" runat="server" />
                                                        </td>
                                                        <td>
                                                            <asp:LinkButton id="addExisting" cssclass="CommandButton" OnClick="AddUser_Click" Text="Add existing user to role" runat="server" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td>
                                                <asp:DataList id="usersInRole" RepeatColumns="2" OnItemCommand="usersInRole_ItemCommand" DataKeyField="UserId" runat="server">
                                                    <ItemStyle Width="225" />
                                                    <ItemTemplate>
                                                        &nbsp;&nbsp;<asp:ImageButton ImageUrl="~/images/delete.gif" CommandName="delete" AlternateText="Remove this user from role" runat="server" />
                                                        <asp:Label Text='<%# DataBinder.Eval(Container.DataItem, "Email") %>' cssclass="Normal" runat="server" />
                                                    </ItemTemplate>
                                                </asp:DataList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:LinkButton id="saveBtn" class="CommandButton" Text="Save Role Changes" onclick="Save_Click" runat="server" />
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
