<%@ Page language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="ASPNetPortal" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%--
    The SecurityRoles.aspx page is used to create and edit security roles within
    the Portal application.
--%>
<script runat="server">

    int    userId   = -1;
    String userName = "";
    int tabIndex = 0;
    int tabId = 0;

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

        // Calculate userid
        if (Request.Params["userid"] != null) {
            userId = Int32.Parse(Request.Params["userid"]);
        }
        if (Request.Params["username"] != null) {
            userName = (String)Request.Params["username"];
        }
        if (Request.Params["tabid"] != null) {
            tabId = Int32.Parse(Request.Params["tabid"]);
        }
        if (Request.Params["tabindex"] != null) {
            tabIndex = Int32.Parse(Request.Params["tabindex"]);
        }


        // If this is the first visit to the page, bind the role data to the datalist
        if (Page.IsPostBack == false) {

            // new user?
            if (userName == "") {

                UsersDB users = new UsersDB();

                // make a unique new user record
                int uid = -1;
                int i = 0;

                while (uid == -1) {

                    String friendlyName = "New User created " + DateTime.Now.ToString();
                    userName = "New User" + i.ToString();
                    uid = users.AddUser(friendlyName, userName, "");
                    i++;
                }

                // redirect to this page with the corrected querystring args
                Response.Redirect("~/Admin/ManageUsers.aspx?userId=" + uid + "&username=" + userName + "&tabindex=" + tabIndex + "&tabid=" + tabId);
            }

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
    // The AddRole_Click server event handler is used to add
    // the user to this security role
    //
    //*******************************************************

    void AddRole_Click(Object sender, EventArgs e) {

        int roleId;

        //get user id from dropdownlist of existing users
        roleId = Int32.Parse(allRoles.SelectedItem.Value);

        // Add a new userRole to the database
        AdminDB admin = new AdminDB();
        admin.AddUserRole(roleId, userId);

        // Rebind list
        BindData();
    }

    //*******************************************************
    //
    // The UpdateUser_Click server event handler is used to add
    // the update the user settings
    //
    //*******************************************************

    void UpdateUser_Click(Object sender, EventArgs e) {

        // update the user record in the database
        UsersDB users = new UsersDB();
        users.UpdateUser(userId, Email.Text, Password.Text);

        // redirect to this page with the corrected querystring args
        Response.Redirect("~/Admin/ManageUsers.aspx?userId=" + userId + "&username=" + Email.Text + "&tabindex=" + tabIndex + "&tabid=" + tabId);
    }

    //*******************************************************
    //
    // The UserRoles_ItemCommand server event handler on this page
    // is used to handle deleting the user from roles
    // from the userRoles asp:datalist control
    //
    //*******************************************************

    void UserRoles_ItemCommand(object sender, DataListCommandEventArgs e) {

        AdminDB admin = new AdminDB();
        int roleId = (int) userRoles.DataKeys[e.Item.ItemIndex];

        // update database
        admin.DeleteUserRole(roleId, userId);

        // Ensure that item is not editable
        userRoles.EditItemIndex = -1;

        // Repopulate list
        BindData();
    }

    //*******************************************************
    //
    // The BindData helper method is used to bind the list of
    // security roles for this portal to an asp:datalist server control
    //
    //*******************************************************

    void BindData() {

        // Bind the Email and Password
        UsersDB users = new UsersDB();
        SqlDataReader dr = users.GetSingleUser(userName);

        // Read first row from database
        dr.Read();

        Email.Text = (String) dr["Email"];
        Password.Text = (String) dr["Password"];

        dr.Close();

        // add the user name to the title
        if (userName != "") {

            title.InnerText = "Manage User: " + userName;
        }

        // bind users in role to DataList
        userRoles.DataSource = users.GetRolesByUser(userName);
        userRoles.DataBind();

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

        // Get the portal's roles from the database
        AdminDB admin = new AdminDB();

        // bind all portal roles to dropdownlist
        allRoles.DataSource = admin.GetPortalRoles(portalSettings.PortalId);
        allRoles.DataBind();
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
                    <td width="100">
                        &nbsp;
                    </td>
                    <td>
                        <br>
                        <table width="450" cellspacing="0" cellpadding="4" border="0">
                            <tr height="*" valign="top">
                                <td colspan="2">
                                    <table width="100%" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="left">
                                                <span id="title" class="Head" runat="server">Manage User</span>
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
                                <td class="Normal">
                                    Email (or Windows domain name):
                                </td>
                                <td>
                                    <asp:Textbox id="Email" width="200" cssclass="NormalTextBox" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td class="Normal">
                                    Password:
                                </td>
                                <td>
                                    <asp:Textbox id="Password" width="200" cssclass="NormalTextBox" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <asp:LinkButton Text="Apply Name and Password Changes" OnClick="UpdateUser_Click" cssclass="CommandButton" runat="server" ID="Linkbutton1" />
                                    <br>
                                    <br>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:DropDownList id="allRoles" DataTextField="RoleName" DataValueField="RoleID" runat="server" />
                                    &nbsp;<asp:LinkButton id="addExisting" cssclass="CommandButton" OnClick="AddRole_Click" Text="Add user to this role" runat="server" />
                                </td>
                            </tr>
                            <tr valign="top">
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    <asp:DataList id="userRoles" RepeatColumns="2" OnItemCommand="UserRoles_ItemCommand" DataKeyField="RoleId" runat="server">
                                        <ItemStyle Width="225" />
                                        <ItemTemplate>
                                            &nbsp;&nbsp;<asp:ImageButton ImageUrl="~/images/delete.gif" CommandName="delete" AlternateText="Remove user from this role" runat="server" ID="Imagebutton1" />
                                            <asp:Label Text='<%# DataBinder.Eval(Container.DataItem, "RoleName") %>' cssclass="Normal" runat="server" ID="Label1" />
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
                                    <asp:LinkButton id="saveBtn" class="CommandButton" Text="Save User Changes" onclick="Save_Click" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
