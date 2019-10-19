<%@ Control Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<%@ Import Namespace="ASPNetPortal" %>
<script language="C#" runat="server">

    int tabIndex = 0;
    int tabId = 0;

    //*******************************************************
    //
    // The Page_Load server event handler on this user control is used
    // to populate the current defs settings from the configuration system
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

        // If this is the first visit to the page, bind the definition data to the datalist
        if (Page.IsPostBack == false) {

			BindData();
        }
    }

    //*******************************************************
    //
    // The AddDef_Click server event handler is used to add
    // a new module definition for this portal
    //
    //*******************************************************

    void AddDef_Click(Object Sender, EventArgs e) {

        // redirect to edit page
        Response.Redirect("~/Admin/ModuleDefinitions.aspx?defId=-1&tabindex=" + tabIndex + "&tabid=" + tabId);
    }

    //*******************************************************
    //
    // The DefsList_ItemCommand server event handler on this page 
    // is used to handle the user editing module definitions
    // from the DefsList asp:datalist control
    //
    //*******************************************************

    void DefsList_ItemCommand(object sender, DataListCommandEventArgs e) {

        int moduleDefId = (int) defsList.DataKeys[e.Item.ItemIndex];

        // redirect to edit page
        Response.Redirect("~/Admin/ModuleDefinitions.aspx?defId=" + moduleDefId + "&tabindex=" + tabIndex + "&tabid=" + tabId);
    }
    
	//*******************************************************
    //
    // The BindData helper method is used to bind the list of 
    // module definitions for this portal to an asp:datalist server control
    //
    //*******************************************************

    void BindData() {

    	// Obtain PortalSettings from Current Context
		PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];
		
		// Get the portal's defs from the database
        AdminDB admin = new AdminDB();
        
        defsList.DataSource = admin.GetModuleDefinitions(portalSettings.PortalId);
        defsList.DataBind();
    }
    
</script>
<portal:title runat="server" id="Title1" />
<table cellpadding="2" cellspacing="0" border="0">
    <tr valign="top">
        <td>
            <asp:DataList id="defsList" OnItemCommand="DefsList_ItemCommand" DataKeyField="ModuleDefID" runat="server">
                <ItemTemplate>
                    <asp:ImageButton ImageUrl="~/images/edit.gif" AlternateText="Edit this item" runat="server" />
                    &nbsp;&nbsp;
                    <asp:Label Text='<%# DataBinder.Eval(Container.DataItem, "FriendlyName") %>' CssClass="Normal" runat="server" />
                </ItemTemplate>
            </asp:DataList>
        </td>
    </tr>
    <tr>
        <td>
            <asp:LinkButton cssclass="CommandButton" OnClick="AddDef_Click" Text="Add New Module Type" runat="server" />
        </td>
    </tr>
</table>
