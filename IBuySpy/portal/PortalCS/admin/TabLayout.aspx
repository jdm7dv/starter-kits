<%@ Page language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="ASPNetPortal" %>
<%--
     The TabLayout.aspx page is used to control the layout settings of an
     individual tab within the portal.
--%>
<script runat="server">

    int tabId = 0;
    ArrayList leftList;
    ArrayList contentList;
    ArrayList rightList;

    //*******************************************************
    //
    // The Page_Load server event handler on this page is used
    // to populate a tab's layout settings on the page
    //
    //*******************************************************

    void Page_Load(Object Sender, EventArgs e) {

        // Verify that the current user has access to access this page
        if (PortalSecurity.IsInRoles("Admins") == false) {
            Response.Redirect("~/Admin/EditAccessDenied.aspx");
        }

        // Determine Tab to Edit
        if (Request.Params["tabid"] != null) {
            tabId = Int32.Parse(Request.Params["tabid"]);
        }

        // If first visit to the page, update all entries
        if (Page.IsPostBack == false) {

            BindData();
        }
    }

    //*******************************************************
    //
    // The AddModuleToPane_Click server event handler on this page is used
    // to add a new portal module into the tab
    //
    //*******************************************************

    void AddModuleToPane_Click(Object sender, EventArgs e) {

        // All new modules go to the end of the contentpane
        ModuleItem m = new ModuleItem();
        m.ModuleTitle = moduleTitle.Text;
        m.ModuleDefId = Int32.Parse(moduleType.SelectedItem.Value);
        m.ModuleOrder = 999;
        
        // save to database
        AdminDB admin = new AdminDB();
        m.ModuleId = admin.AddModule(tabId, m.ModuleOrder, "ContentPane", m.ModuleTitle, m.ModuleDefId, 0, "Admins", false);
        
        // Obtain portalId from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

        // reload the portalSettings from the database
        HttpContext.Current.Items["PortalSettings"] = new PortalSettings(portalSettings.PortalId, tabId);
        
        // reorder the modules in the content pane
        ArrayList modules = GetModules("ContentPane");
        OrderModules(modules);
        
        // resave the order
        foreach (ModuleItem item in modules) {
            admin.UpdateModuleOrder(item.ModuleId, item.ModuleOrder, "ContentPane");
        }

        // Redirect to the same page to pick up changes
        Response.Redirect(Request.RawUrl);
    }

    //*******************************************************
    //
    // The UpDown_Click server event handler on this page is
    // used to move a portal module up or down on a tab's layout pane
    //
    //*******************************************************

    void UpDown_Click(Object sender, ImageClickEventArgs e) {

        String cmd = ((ImageButton)sender).CommandName;
        String pane = ((ImageButton)sender).CommandArgument;
        ListBox _listbox = (ListBox) Page.FindControl(pane);
               
        ArrayList modules = GetModules(pane);
        
        if (_listbox.SelectedIndex != -1) {

            int delta;
            int selection = -1; 
            
            // Determine the delta to apply in the order number for the module
            // within the list.  +3 moves down one item; -3 moves up one item
            
            if (cmd == "down") {
            
                delta = 3;
                if (_listbox.SelectedIndex < _listbox.Items.Count-1)
                    selection = _listbox.SelectedIndex + 1;
            }
            else {
            
                delta = -3;
                if (_listbox.SelectedIndex > 0)
                    selection = _listbox.SelectedIndex - 1;
            }

            ModuleItem m;
            m = (ModuleItem) modules[_listbox.SelectedIndex];
            m.ModuleOrder += delta; 
            
            // reorder the modules in the content pane
            OrderModules(modules);
        
            // resave the order
            AdminDB admin = new AdminDB();
            foreach (ModuleItem item in modules) {
                admin.UpdateModuleOrder(item.ModuleId, item.ModuleOrder, pane);
            }
        }
        
        // Redirect to the same page to pick up changes
        Response.Redirect(Request.RawUrl);
    }

    //*******************************************************
    //
    // The RightLeft_Click server event handler on this page is
    // used to move a portal module between layout panes on
    // the tab page
    //
    //*******************************************************

    void RightLeft_Click(Object sender, ImageClickEventArgs e) {

        String sourcePane = ((ImageButton)sender).Attributes["sourcepane"];
        String targetPane = ((ImageButton)sender).Attributes["targetpane"];
        ListBox sourceBox = (ListBox) Page.FindControl(sourcePane);
        ListBox targetBox = (ListBox) Page.FindControl(targetPane);
         
        if (sourceBox.SelectedIndex != -1) {

            // get source arraylist
            ArrayList sourceList = GetModules(sourcePane);
        
            // get a reference to the module to move
            // and assign a high order number to send it to the end of the target list
            ModuleItem m = (ModuleItem) sourceList[sourceBox.SelectedIndex];
            
            // add it to the database
            AdminDB admin = new AdminDB();
            admin.UpdateModuleOrder(m.ModuleId, 998, targetPane);

            // delete it from the source list
            sourceList.RemoveAt(sourceBox.SelectedIndex);

            // Obtain portalId from Current Context
            PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

            // reload the portalSettings from the database
            HttpContext.Current.Items["PortalSettings"] = new PortalSettings(portalSettings.PortalId, tabId);
            
            // reorder the modules in the source pane
            sourceList = GetModules(sourcePane);
            OrderModules(sourceList);
            
            // resave the order
            foreach (ModuleItem item in sourceList) {
                admin.UpdateModuleOrder(item.ModuleId, item.ModuleOrder, sourcePane);
            }           
            
            // reorder the modules in the target pane
            ArrayList targetList = GetModules(targetPane);
            OrderModules(targetList);
                        
            // resave the order
            foreach (ModuleItem item in targetList) {
                admin.UpdateModuleOrder(item.ModuleId, item.ModuleOrder, targetPane);
            }           
            
            // Redirect to the same page to pick up changes
            Response.Redirect(Request.RawUrl);
        }
    }

    //*******************************************************
    //
    // The Apply_Click server event handler on this page is
    // used to save the current tab settings to the database and 
    // then redirect back to the main admin page.
    //
    //*******************************************************

    void Apply_Click(Object Sender, EventArgs e) {

        // Save changes then navigate back to admin.  
        String id = (String)((LinkButton)Sender).ID;
        
        SaveTabData();

        // redirect back to the admin page
        
        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];
        int adminIndex = portalSettings.DesktopTabs.Count-1;        
       
        Response.Redirect("~/DesktopDefault.aspx?tabindex=" + adminIndex.ToString() + "&tabid=" + ((TabStripDetails)portalSettings.DesktopTabs[adminIndex]).TabId);       
    }

    //*******************************************************
    //
    // The TabSettings_Change server event handler on this page is
    // invoked any time the tab name or access security settings
    // change.  The event handler in turn calls the "SaveTabData"
    // helper method to ensure that these changes are persisted
    // to the portal configuration file.
    //
    //*******************************************************

    void TabSettings_Change(Object sender, EventArgs e) {

        // Ensure that settings are saved
        SaveTabData();
    }

    //*******************************************************
    //
    // The SaveTabData helper method is used to persist the
    // current tab settings to the database.
    //
    //*******************************************************

    void SaveTabData() {
    
        // Construct Authorized User Roles String
        String authorizedRoles = "";

        foreach(ListItem item in authRoles.Items) {

            if (item.Selected == true) {
                authorizedRoles = authorizedRoles + item.Text + ";";
            }
        }
        
        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

        // update Tab info in the database
        AdminDB admin = new AdminDB();
        admin.UpdateTab(portalSettings.PortalId, tabId, tabName.Text, portalSettings.ActiveTab.TabOrder, authorizedRoles, mobileTabName.Text, showMobile.Checked);
    }
    
    //*******************************************************
    //
    // The EditBtn_Click server event handler on this page is
    // used to edit an individual portal module's settings
    //
    //*******************************************************

    void EditBtn_Click(Object sender, ImageClickEventArgs e) {

        String pane = ((ImageButton)sender).CommandArgument;
        ListBox _listbox = (ListBox) Page.FindControl(pane);

        if (_listbox.SelectedIndex != -1) {

            int mid = Int32.Parse(_listbox.SelectedItem.Value);
            
            // Redirect to module settings page
            Response.Redirect("ModuleSettings.aspx?mid=" + mid + "&tabid=" + tabId);
        }
    }

    //*******************************************************
    //
    // The DeleteBtn_Click server event handler on this page is
    // used to delete an portal module from the page
    //
    //*******************************************************

    void DeleteBtn_Click(Object sender, ImageClickEventArgs e) {

        String pane = ((ImageButton)sender).CommandArgument;
        ListBox _listbox = (ListBox) Page.FindControl(pane);
        ArrayList modules = GetModules(pane);

        if (_listbox.SelectedIndex != -1) {

            ModuleItem m = (ModuleItem) modules[_listbox.SelectedIndex];
            if (m.ModuleId > -1) {
            
                // must delete from database too
                AdminDB admin = new AdminDB();
                admin.DeleteModule(m.ModuleId);
            }
        }

        // Redirect to the same page to pick up changes
        Response.Redirect(Request.RawUrl);
    }


    //*******************************************************
    //
    // The BindData helper method is used to update the tab's
    // layout panes with the current configuration information
    //
    //*******************************************************

    void BindData() {

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];
        TabSettings tab = portalSettings.ActiveTab;

        // Populate Tab Names, etc.
        tabName.Text = tab.TabName;
        mobileTabName.Text = tab.MobileTabName;
        showMobile.Checked = tab.ShowMobile;

        // Populate checkbox list with all security roles for this portal
        // and "check" the ones already configured for this tab
        AdminDB admin = new AdminDB();
        SqlDataReader roles = admin.GetPortalRoles(portalSettings.PortalId);

        // Clear existing items in checkboxlist
        authRoles.Items.Clear();

        ListItem allItem = new ListItem();
        allItem.Text = "All Users";

        if (tab.AuthorizedRoles.LastIndexOf("All Users") > -1) {
            allItem.Selected = true;
        }

        authRoles.Items.Add(allItem);

        while(roles.Read()) {

            ListItem item = new ListItem();
            item.Text = (String) roles["RoleName"];
            item.Value = roles["RoleID"].ToString();
            
            if ((tab.AuthorizedRoles.LastIndexOf(item.Text)) > -1) {
                item.Selected = true;
            }

            authRoles.Items.Add(item);
        }

        // Populate the "Add Module" Data
        moduleType.DataSource = admin.GetModuleDefinitions(portalSettings.PortalId);
        moduleType.DataBind();

        // Populate Right Hand Module Data
        rightList = GetModules("RightPane");
        rightPane.DataBind();

        // Populate Content Pane Module Data
        contentList = GetModules("ContentPane");
        contentPane.DataBind();

        // Populate Left Hand Pane Module Data
        leftList = GetModules("LeftPane");
        leftPane.DataBind();
    }
    
    //*******************************************************
    //
    // The GetModules helper method is used to get the modules
    // for a single pane within the tab
    //
    //*******************************************************

    ArrayList GetModules (String pane) {
    
        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];
        ArrayList paneModules = new ArrayList();
        
        foreach (ModuleSettings module in portalSettings.ActiveTab.Modules) {
            
            if ((module.PaneName).ToLower() == pane.ToLower()) {
            
                ModuleItem m = new ModuleItem();
                m.ModuleTitle = module.ModuleTitle;
                m.ModuleId = module.ModuleId;
                m.ModuleDefId = module.ModuleDefId;
                m.ModuleOrder = module.ModuleOrder;
                paneModules.Add(m);
            }
        }
        
        return paneModules;
    }

    //*******************************************************
    //
    // The OrderModules helper method is used to reset the display
    // order for modules within a pane
    //
    //*******************************************************

    void OrderModules (ArrayList list) {
    
        int i = 1;
        
        // sort the arraylist
        list.Sort();
        
        // renumber the order
        foreach (ModuleItem m in list) {
        
            // number the items 1, 3, 5, etc. to provide an empty order
            // number when moving items up and down in the list.
            m.ModuleOrder = i;
            i += 2;
        }
    }

</script>
<HTML>
    <HEAD>
        <link rel="stylesheet" href='<%= Request.ApplicationPath + "/Portal.css" %>' type="text/css">
    </HEAD>
    <body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0" marginheight="0" marginwidth="0">
        <form runat="server">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr valign="top">
                    <td colspan="2">
                        <portal:Banner ShowTabs="false" runat="server" id="Banner1" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <br>
                        <table width="98%" cellspacing="0" cellpadding="4">
                            <tr valign="top">
                                <td width="150">
                                    &nbsp;
                                </td>
                                <td width="*">
                                    <table border="0" cellpadding="2" cellspacing="1">
                                        <tr>
                                            <td colspan="4">
                                                <table width="100%" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td align="left" class="Head">
                                                            Tab Name and Layout
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <hr noshade size="1">
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="100" class="Normal">
                                                Tab Name:
                                            </td>
                                            <td colspan="3">
                                                <asp:Textbox id="tabName" width="300" OnTextChanged="TabSettings_Change" cssclass="NormalTextBox" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="Normal" nowrap>
                                                Authorized Roles:
                                            </td>
                                            <td colspan="3">
                                                <asp:CheckBoxList id="authRoles" OnSelectedIndexChanged="TabSettings_Change" RepeatColumns="2" Font-Names="Verdana,Arial" Font-Size="8pt" width="300" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td colspan="3">
                                                <hr noshade size="1">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="Normal" nowrap>
                                                Show to mobile users?:
                                            </td>
                                            <td colspan="3">
                                                <asp:Checkbox id="showMobile" OnCheckedChanged="TabSettings_Change" Font-Names="Verdana,Arial" Font-Size="8pt" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="Normal" nowrap>
                                                Mobile Tab Name:
                                            </td>
                                            <td colspan="3">
                                                <asp:Textbox id="mobileTabName" width="300" OnTextChanged="TabSettings_Change" cssclass="NormalTextBox" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="4">
                                                <hr noshade size="1">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="Normal">
                                                Add Module:
                                            </td>
                                            <td class="Normal">
                                                Module Type
                                            </td>
                                            <td colspan="2">
                                                <asp:DropDownList id="moduleType" DataValueField="ModuleDefID" DataTextField="FriendlyName" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td class="Normal">
                                                Module Name:
                                            </td>
                                            <td colspan="2">
                                                <asp:Textbox id="moduleTitle" EnableViewState="false" Text="New Module Name" cssclass="NormalTextBox" width="250" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td colspan="3">
                                                <asp:LinkButton class="CommandButton" onclick="AddModuleToPane_Click" Text='<img src="../images/dn.gif" border=0> Add to "Organize Modules" Below' runat="server" id="LinkButton1" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                &nbsp;
                                            </td>
                                            <td colspan="3">
                                                <hr noshade size="1">
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td class="Normal">
                                                Organize Modules:
                                            </td>
                                            <td width="120">
                                                <table border="0" cellspacing="0" cellpadding="2" width="100%">
                                                    <tr>
                                                        <td class="NormalBold">
                                                            &nbsp;Left Mini Pane
                                                        </td>
                                                    </tr>
                                                    <tr valign="top">
                                                        <td>
                                                            <table border="0" cellspacing="2" cellpadding="0">
                                                                <tr valign="top">
                                                                    <td rowspan="2">
                                                                        <asp:ListBox id="leftPane" DataSource="<%# leftList %>" DataTextField="ModuleTitle" DataValueField="ModuleId" width="110" rows="7" runat="server" />
                                                                    </td>
                                                                    <td valign="top" nowrap>
                                                                        <asp:ImageButton ImageUrl="~/images/up.gif" onclick="UpDown_Click" CommandName="up" CommandArgument="leftPane" AlternateText="Move selected module up in list" runat="server" id="ImageButton1" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/rt.gif" onclick="RightLeft_Click" CommandName="right" sourcepane="leftPane" targetpane="contentPane" AlternateText="Move selected module to the content pane" runat="server" id="ImageButton2" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/dn.gif" onclick="UpDown_Click" CommandName="down" CommandArgument="leftPane" AlternateText="Move selected module down in list" runat="server" id="ImageButton3" />
                                                                        &nbsp;&nbsp;
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="bottom" nowrap>
                                                                        <asp:ImageButton ImageUrl="~/images/edit.gif" onclick="EditBtn_Click" CommandName="edit" CommandArgument="leftPane" AlternateText="Edit this item" runat="server" id="ImageButton4" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/delete.gif" onclick="DeleteBtn_Click" CommandName="delete" CommandArgument="leftPane" AlternateText="Delete this item" runat="server" id="ImageButton5" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td width="*">
                                                <table border="0" cellspacing="0" cellpadding="2" width="100%">
                                                    <tr>
                                                        <td class="NormalBold">
                                                            &nbsp;Content Pane
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="middle">
                                                            <table border="0" cellspacing="2" cellpadding="0">
                                                                <tr valign="top">
                                                                    <td rowspan="2">
                                                                        <asp:ListBox id="contentPane" DataSource="<%# contentList %>" DataTextField="ModuleTitle" DataValueField="ModuleId" width="170" rows="7" runat="server" />
                                                                    </td>
                                                                    <td valign="top" nowrap>
                                                                        <asp:ImageButton ImageUrl="~/images/up.gif" onclick="UpDown_Click" CommandName="up" CommandArgument="contentPane" AlternateText="Move selected module up in list" runat="server" id="ImageButton6" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/lt.gif" onclick="RightLeft_Click" sourcepane="contentPane" targetpane="leftPane" AlternateText="Move selected module to the left pane" runat="server" id="ImageButton7" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/rt.gif" onclick="RightLeft_Click" sourcepane="contentPane" targetpane="rightPane" AlternateText="Move selected module to the right pane" runat="server" id="ImageButton8" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/dn.gif" onclick="UpDown_Click" CommandName="down" CommandArgument="contentPane" AlternateText="Move selected module down in list" runat="server" id="ImageButton9" />
                                                                        &nbsp;&nbsp;
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="bottom" nowrap>
                                                                        <asp:ImageButton ImageUrl="~/images/edit.gif" onclick="EditBtn_Click" CommandName="edit" CommandArgument="contentPane" AlternateText="Edit this item" runat="server" id="ImageButton10" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/delete.gif" onclick="DeleteBtn_Click" CommandName="delete" CommandArgument="contentPane" AlternateText="Delete this item" runat="server" id="ImageButton11" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td width="120">
                                                <table border="0" cellspacing="0" cellpadding="2" width="100%">
                                                    <tr>
                                                        <td class="NormalBold">
                                                            &nbsp;Right Mini Pane
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <table border="0" cellspacing="2" cellpadding="0">
                                                                <tr valign="top">
                                                                    <td rowspan="2">
                                                                        <asp:ListBox id="rightPane" DataSource="<%# rightList %>" DataTextField="ModuleTitle" DataValueField="ModuleId" width="110" rows="7" runat="server" />
                                                                    </td>
                                                                    <td valign="top" nowrap>
                                                                        <asp:ImageButton ImageUrl="~/images/up.gif" onclick="UpDown_Click" CommandName="up" CommandArgument="rightPane" AlternateText="Move selected module up in list" runat="server" id="ImageButton12" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/lt.gif" onclick="RightLeft_Click" sourcepane="rightPane" targetpane="contentPane" AlternateText="Move selected module to the left pane" runat="server" id="ImageButton13" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/dn.gif" onclick="UpDown_Click" CommandName="down" CommandArgument="rightPane" AlternateText="Move selected module down in list" runat="server" id="ImageButton14" />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="bottom" nowrap>
                                                                        <asp:ImageButton ImageUrl="~/images/edit.gif" onclick="EditBtn_Click" CommandName="edit" CommandArgument="rightPane" AlternateText="Edit this item" runat="server" id="ImageButton15" />
                                                                        <br>
                                                                        <asp:ImageButton ImageUrl="~/images/delete.gif" onclick="DeleteBtn_Click" CommandName="delete" CommandArgument="rightPane" AlternateText="Delete this item" runat="server" id="ImageButton16" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="4">
                                                <hr noshade size="1">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="4">
                                                <asp:LinkButton id="applyBtn" class="CommandButton" Text="Apply Changes" onclick="Apply_Click" runat="server" />
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
</HTML>
