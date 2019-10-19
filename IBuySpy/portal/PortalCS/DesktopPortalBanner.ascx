<%@ Import Namespace="ASPNetPortal" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%--

   The DesktopPortalBanner User Control is responsible for displaying the standard Portal
   banner at the top of each .aspx page.

   The DesktopPortalBanner uses the Portal Configuration System to obtain a list of the
   portal's sitename and tab settings. It then render's this content into the page.

--%>

<script language="C#" runat="server">

    public int          tabIndex;
    public bool         ShowTabs = true;
    protected String    LogoffLink = "";

    void Page_Load(Object sender, EventArgs e) {

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) HttpContext.Current.Items["PortalSettings"];

        // Dynamically Populate the Portal Site Name
        siteName.Text = portalSettings.PortalName;

        // If user logged in, customize welcome message
        if (Request.IsAuthenticated == true) {
        
            WelcomeMessage.Text = "Welcome " + Context.User.Identity.Name + "! <" + "span class=Accent" + ">|<" + "/span" + ">";

            // if authentication mode is Cookie, provide a logoff link
            if (Context.User.Identity.AuthenticationType == "Forms") {
                LogoffLink = "<" + "span class=\"Accent\">|</span>\n" + "<" + "a href=" + Request.ApplicationPath + "/Admin/Logoff.aspx class=SiteLink> Logoff" + "<" + "/a>";
            }
        }

        // Dynamically render portal tab strip
        if (ShowTabs == true) {

            tabIndex = portalSettings.ActiveTab.TabIndex;

            // Build list of tabs to be shown to user                                   
            ArrayList authorizedTabs = new ArrayList();
            int addedTabs = 0;

            for (int i=0; i < portalSettings.DesktopTabs.Count; i++) {
            
                TabStripDetails tab = (TabStripDetails)portalSettings.DesktopTabs[i];

                if (PortalSecurity.IsInRoles(tab.AuthorizedRoles)) { 
                    authorizedTabs.Add(tab);
                }

                if (addedTabs == tabIndex) {
                    tabs.SelectedIndex = addedTabs;
                }

                addedTabs++;
            }          

            // Populate Tab List at Top of the Page with authorized tabs
            tabs.DataSource = authorizedTabs;
            tabs.DataBind();
        }
    }

</script>
<table width="100%" cellspacing="0" class="HeadBg" border="0">
    <tr valign="top">
        <td colspan="3" class="SiteLink" background="<%= Request.ApplicationPath %>/images/bars.gif" align="right">
            <asp:label id="WelcomeMessage" forecolor="#eeeeee" runat="server" />
            <a href="<%= Request.ApplicationPath %>" class="SiteLink">Portal Home</a> <span class="Accent">
                |</span> <a href="<%= Request.ApplicationPath %>/Docs/Docs.htm" target="_blank" class="SiteLink">
                Portal Documentation</a>
            <%= LogoffLink %>
            &nbsp;&nbsp;
        </td>
    </tr>
    <tr>
        <td width="10" rowspan="2">
            &nbsp;
        </td>
        <td height="40">
            <asp:label id="siteName" CssClass="SiteTitle" EnableViewState="false" runat="server" />
        </td>
        <td align="center" rowspan="2">
            <a href="http://www.asp.net"><img id="logo" src="<%=Request.ApplicationPath%>/images/poweredby_simple.gif" border="0"></a>
        </td>
    </tr>
    <tr>
        <td>
            <asp:datalist id="tabs" cssclass="OtherTabsBg" repeatdirection="horizontal" ItemStyle-Height="25" SelectedItemStyle-CssClass="TabBg" ItemStyle-BorderWidth="1" EnableViewState="false" runat="server">
                <ItemTemplate>
                    &nbsp;<a href='<%= Request.ApplicationPath %>/DesktopDefault.aspx?tabindex=<%# Container.ItemIndex %>&tabid=<%# ((TabStripDetails) Container.DataItem).TabId %>' class="OtherTabs"><%# ((TabStripDetails) Container.DataItem).TabName %></a>&nbsp;
                </ItemTemplate>
                <SelectedItemTemplate>
                    &nbsp;<span class="SelectedTab"><%# ((TabStripDetails) Container.DataItem).TabName %></span>&nbsp;
                </SelectedItemTemplate>
            </asp:datalist>
        </td>
    </tr>
</table>
