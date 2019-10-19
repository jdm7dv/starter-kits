<%@ Page language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="DesktopPortalBanner.ascx" %>
<%@ Import Namespace="ASPNetPortal" %>
<%@ Import Namespace="System.Data" %>

<%--

   The DesktopDefault.aspx page is used to load and populate each Portal View.  It accomplishes
   this by reading the layout configuration of the portal from the Portal Configuration
   system, and then using this information to dynamically instantiate portal modules
   (each implemented as an ASP.NET User Control), and then inject them into the page.

--%>

<script runat="server">

    //*********************************************************************
    //
    // Page_Init Event Handler
    //
    // The Page_Init event handler executes at the very beginning of each page
    // request (immediately before Page_Load).
    //
    // The Page_Init event handler below determines the tab index of the currently
    // requested portal view, and then calls the PopulatePortalSection utility
    // method to dynamically populate the left, center and right hand sections
    // of the portal tab.
    //
    //*********************************************************************

    void Page_Init(Object sender, EventArgs e) {

        // Obtain PortalSettings from Current Context
        PortalSettings portalSettings = (PortalSettings) HttpContext.Current.Items["PortalSettings"];
        
        // Ensure that the visiting user has access to the current page
        if (PortalSecurity.IsInRoles(portalSettings.ActiveTab.AuthorizedRoles) == false) {
            Response.Redirect("~/Admin/AccessDenied.aspx");
        }

        // Dynamically inject a signin login module into the top left-hand corner
        // of the home page if the client is not yet authenticated
        if ((Request.IsAuthenticated == false) && (portalSettings.ActiveTab.TabIndex == 0)) {
            LeftPane.Controls.Add(Page.LoadControl("~/DesktopModules/SignIn.ascx"));
            LeftPane.Visible = true;             
        }

        // Dynamically Populate the Left, Center and Right pane sections of the portal page
        if (portalSettings.ActiveTab.Modules.Count > 0) {

            // Loop through each entry in the configuration system for this tab
            foreach (ModuleSettings _moduleSettings in portalSettings.ActiveTab.Modules) {
                
                Control parent = Page.FindControl(_moduleSettings.PaneName);

                // If no caching is specified, create the user control instance and dynamically
                // inject it into the page.  Otherwise, create a cached module instance that
                // may or may not optionally inject the module into the tree

                if ((_moduleSettings.CacheTime) == 0) {

                   PortalModuleControl portalModule = (PortalModuleControl) Page.LoadControl(_moduleSettings.DesktopSrc);
                   
                   portalModule.PortalId = portalSettings.PortalId;                                  
                   portalModule.ModuleConfiguration = _moduleSettings;
                   
                   parent.Controls.Add(portalModule);
                }
                else {

                   CachedPortalModuleControl portalModule = new CachedPortalModuleControl();
                   
                   portalModule.PortalId = portalSettings.PortalId;                                 
                   portalModule.ModuleConfiguration = _moduleSettings;
 
                   parent.Controls.Add(portalModule);
                }

                // Dynamically inject separator break between portal modules
                parent.Controls.Add(new LiteralControl("<" + "br" + ">"));
                parent.Visible = true;
            }
        }
    }

</script>
<html>
    <head>
        <title>ASP.NET Portal</title>
        <link href="portal.css" type="text/css" rel="stylesheet" />
    </head>
    <body leftmargin="0" bottommargin="0" rightmargin="0" topmargin="0" marginheight="0" marginwidth="0">
        <form runat="server">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr valign="top">
                    <td colspan="2">
                        <portal:Banner id="Banner" SelectedTabIndex="0" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <br>
                        <table width="100%" cellspacing="0" cellpadding="4" border="0">
                            <tr height="*" valign="top">
                                <td width="5">
                                    &nbsp;
                                </td>
                                <td id="LeftPane" Visible="false" Width="170" runat="server">
                                </td>
                                <td width="1">
                                </td>
                                <td id="ContentPane" Visible="false" Width="*" runat="server">
                                </td>
                                <td id="RightPane" Visible="false" Width="230" runat="server">
                                </td>
                                <td width="10">
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
