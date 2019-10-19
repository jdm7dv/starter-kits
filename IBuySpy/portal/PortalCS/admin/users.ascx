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
    // The DeleteUser_Click server event handler is used to add
    // a new security role for this portal
    //
    //*******************************************************

    void DeleteUser_Click(Object Sender, ImageClickEventArgs e) {

        // get user id from dropdownlist of users
        UsersDB users = new UsersDB();
        users.DeleteUser(Int32.Parse(allUsers.SelectedItem.Value));
        
        // Rebind list
        BindData();
    }
    
    //*******************************************************
    //
    // The EditUser_Click server event handler is used to add
    // a new security role for this portal
    //
    //*******************************************************

    void EditUser_Click(Object Sender, CommandEventArgs e) {

        // get user id from dropdownlist of users
        int userId = -1;
        String _userName = "";
        
        if (e.CommandName == "edit") {
        
            userId = Int32.Parse(allUsers.SelectedItem.Value);
            _userName = allUsers.SelectedItem.Text;
        }
        
        // redirect to edit page
        Response.Redirect("~/Admin/ManageUsers.aspx?userId=" + userId + "&username=" + _userName + "&tabindex=" + tabIndex + "&tabid=" + tabId);
    }
    
	//*******************************************************
    //
    // The BindData helper method is used to bind the list of 
    // users for this portal to an asp:DropDownList server control
    //
    //*******************************************************

    void BindData() {
    
        // change the message between Windows and Forms authentication
        if (Context.User.Identity.AuthenticationType != "Forms")
            Message.Text = "Users must be registered to view secure content.  Users may add themselves using the Register form, and Administrators may add users to specific roles using the Security Roles function above.  This section permits Administrators to manage users and their security roles directly.";
        else
            Message.Text = "Domain users do not need to be registered to access portal content that is available to \"All Users\".  Administrators may add domain users to specific roles using the Security Roles function above.  This section permits Administrators to manage users and their security roles directly.";

		// Get the list of registered users from the database
        AdminDB admin = new AdminDB();
        
        // bind all portal users to dropdownlist
        allUsers.DataSource = admin.GetUsers();
        allUsers.DataBind();
    }
    
</script>
<portal:title runat="server" id="Title1" />
<table cellpadding="2" cellspacing="0" border="0">
    <tr valign="top">
        <td width="100">
            &nbsp;
        </td>
        <td class="Normal">
            <asp:Literal id="Message" runat="server" />
            <br><br>
        </td>
    </tr>
    <tr valign="top">
        <td>
            &nbsp;
        </td>
        <td class="Normal">
            Registered Users:&nbsp;
            <asp:DropDownList id="allUsers" DataTextField="Email" DataValueField="UserID" runat="server" />
            &nbsp;
            <asp:ImageButton ImageUrl="~/images/edit.gif" CommandName="edit" OnCommand="EditUser_Click" AlternateText="Edit this user" runat="server" ID="Imagebutton1" />
            <asp:ImageButton ImageUrl="~/images/delete.gif" OnClick="DeleteUser_Click" AlternateText="Delete this user" runat="server" ID="Imagebutton2" />
            &nbsp;
            <asp:LinkButton id="addNew" cssclass="CommandButton" CommandName="Add" Text="Add New User" OnCommand="EditUser_Click" runat="server" />
        </td>
    </tr>
</table>
