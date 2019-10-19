<%@ Import Namespace="ASPNetPortal" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<%@ Control Inherits="ASPNetPortal.PortalModuleControl" %>

<script language="C#" runat="server">

    int tabIndex = 0;
    int tabId = 0;
    ArrayList portalTabs;

    //*******************************************************
    //
    // The Page_Load server event handler on this user control is used
    // to populate the current tab settings from the database
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

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];
        
        portalTabs = new ArrayList();
        foreach (TabStripDetails tab in portalSettings.DesktopTabs) {
        
            TabItem t = new TabItem();
            t.TabName = tab.TabName;
            t.TabId = tab.TabId;
            t.TabOrder = tab.TabOrder;
            portalTabs.Add(t);
        }
        
        // Give the admin tab a big sort order number, to ensure it's
        // always at the end
        TabItem adminTab = (TabItem) portalTabs[portalTabs.Count-1];
        adminTab.TabOrder=99999;
        
        // If this is the first visit to the page, bind the tab data to the page listbox
        if (Page.IsPostBack == false) {

            tabList.DataBind();
        }
    }

    //*******************************************************
    //
    // The UpDown_Click server event handler on this page is
    // used to move a portal module up or down on a tab's layout pane
    //
    //*******************************************************

    void UpDown_Click(Object sender, ImageClickEventArgs e) {

        String cmd = ((ImageButton)sender).CommandName;
        
        if (tabList.SelectedIndex != -1) {

            int delta;
            
            // Determine the delta to apply in the order number for the module
            // within the list.  +3 moves down one item; -3 moves up one item
            
            if (cmd == "down") {
            
                delta = 3;
            }
            else {
            
                delta = -3;
            }

            TabItem t;
            t = (TabItem) portalTabs[tabList.SelectedIndex];
            t.TabOrder += delta; 
            
            // Reset the order numbers for the tabs within the portal  
            OrderTabs();
            
            // Redirect to this site to refresh
            Response.Redirect("~/DesktopDefault.aspx?tabindex=" + (portalTabs.Count-1).ToString() + "&tabid=" + tabId);        }
    }


    //*******************************************************
    //
    // The DeleteBtn_Click server event handler is used to delete
    // the selected tab from the portal
    //
    //*******************************************************

    void DeleteBtn_Click(Object sender, ImageClickEventArgs e) {

        if (tabList.SelectedIndex != -1) {

            // must delete from database too
            TabItem t = (TabItem) portalTabs[tabList.SelectedIndex];
            AdminDB admin = new AdminDB();
            admin.DeleteTab(t.TabId);
                        
            // remove item from list
            portalTabs.RemoveAt(tabList.SelectedIndex);

            // reorder list
            OrderTabs();
            
            // Redirect to this site to refresh
            Response.Redirect("~/DesktopDefault.aspx?tabindex=" + tabIndex + "&tabid=" + tabId);        
        }
    }
    

    //*******************************************************
    //
    // The AddTab_Click server event handler is used to add
    // a new security tab for this portal
    //
    //*******************************************************

    void AddTab_Click(Object Sender, EventArgs e) {

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

        // New tabs go to the end of the list
        TabItem t = new TabItem();
        t.TabName = "New Tab";
        t.TabId = -1;
        t.TabOrder = 999;
        portalTabs.Add(t);

        // write tab to database
		AdminDB admin = new AdminDB();
        t.TabId = admin.AddTab(portalSettings.PortalId, t.TabName, t.TabOrder);
        
        // Reset the order numbers for the tabs within the list  
        OrderTabs();
        
        // Redirect to edit page
		Response.Redirect("~/Admin/TabLayout.aspx?tabid=" + t.TabId);

    }
    
    //*******************************************************
    //
    // The EditBtn_Click server event handler is used to edit
    // the selected tab within the portal
    //
    //*******************************************************

    void EditBtn_Click(Object sender, ImageClickEventArgs e) {

        // Redirect to edit page of currently selected tab
        if (tabList.SelectedIndex != -1) {

            // Redirect to module settings page
            TabItem t = (TabItem) portalTabs[tabList.SelectedIndex];
            
            Response.Redirect("~/Admin/TabLayout.aspx?tabid=" + t.TabId);
        }
    }

    //*******************************************************
    //
    // The OrderTabs helper method is used to reset the display
    // order for tabs within the portal
    //
    //*******************************************************

    void OrderTabs () {
    
        int i = 1;
        
        // sort the arraylist
        portalTabs.Sort();
        
        // renumber the order and save to database
        foreach (TabItem t in portalTabs) {
        
            // number the items 1, 3, 5, etc. to provide an empty order
            // number when moving items up and down in the list.
            t.TabOrder = i;
            i += 2;
            
            // rewrite tab to database
            AdminDB admin = new AdminDB();
            admin.UpdateTabOrder(t.TabId, t.TabOrder);
        }
    }

</script>

<portal:title runat="server" id=Title1 />

<table cellpadding=2 cellspacing=0 border=0>
    <tr>
        <td colspan=2>
            <asp:LinkButton id="addBtn" cssclass="CommandButton" OnClick="AddTab_Click" Text="Add New Tab" runat="server" />
        </td>
    </tr>
    <tr valign="top">
        <td width=100>
            &nbsp;
        </td>
        <td width=50 class="Normal">
            Tabs:
        </td>
        <td>
            <table cellpadding=0 cellspacing=0 border=0>
                <tr valign="top">
                    <td>
                        <asp:ListBox id="tabList" width=200 DataSource="<%# portalTabs %>" DataTextField="TabName" DataValueField="TabId" rows=5 runat="server" />
                    </td>
                    <td>
                        &nbsp;
                    </td>
                    <td>
                        <table>
                            <tr>
                                <td>
                                    <asp:ImageButton id="upBtn" ImageUrl="~/images/up.gif" onclick="UpDown_Click" CommandName="up" AlternateText="Move selected tab up in list" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:ImageButton id="downBtn" ImageUrl="~/images/dn.gif" onclick="UpDown_Click" CommandName="down" AlternateText="Move selected tab down in list" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:ImageButton id="editBtn" ImageUrl="~/images/edit.gif" onclick="EditBtn_Click" AlternateText="Edit selected tab's properties" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:ImageButton id="deleteBtn" ImageUrl="~/images/delete.gif" onclick="DeleteBtn_Click" AlternateText="Delete selected tab" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
