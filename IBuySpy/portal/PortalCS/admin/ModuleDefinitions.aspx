<%@ Page language="C#" %>
<%@ Register TagPrefix="portal" TagName="Banner" Src="~/DesktopPortalBanner.ascx" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="ASPNetPortal" %>
<%--
    The SecurityRoles.aspx page is used to create and edit security roles within
    the Portal application.
--%>
<script runat="server">

    int defId   = -1;
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

        // Calculate security defId
        if (Request.Params["defid"] != null) {
            defId = Int32.Parse(Request.Params["defid"]);
        }
        if (Request.Params["tabid"] != null) {
            tabId = Int32.Parse(Request.Params["tabid"]);
        }
        if (Request.Params["tabindex"] != null) {
            tabIndex = Int32.Parse(Request.Params["tabindex"]);
        }

        
        // If this is the first visit to the page, bind the definition data 
        if (Page.IsPostBack == false) {

            if (defId == -1) {
            
                // new module definition
                FriendlyName.Text = "New Definition";
                DesktopSrc.Text = "DesktopModules/SomeModule.ascx";
                MobileSrc.Text = "MobileModules/SomeModule.ascx";
            }
            else {
            
                // Obtain the module definition to edit from the database
                ASPNetPortal.AdminDB admin = new ASPNetPortal.AdminDB();
                SqlDataReader dr = admin.GetSingleModuleDefinition(defId);
                
                // Read in first row from database
                dr.Read();

                FriendlyName.Text = (String) dr["FriendlyName"];
                DesktopSrc.Text = (String) dr["DesktopSrc"];
                MobileSrc.Text = (String) dr["MobileSrc"];
                
                // Close datareader
                dr.Close();
            }
        }
    }

    //****************************************************************
    //
    // The UpdateBtn_Click event handler on this Page is used to either
    // create or update a link.  It  uses the ASPNetPortal.LinkDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void UpdateBtn_Click(Object sender, EventArgs e) {

        if (Page.IsValid == true) {

            AdminDB admin = new AdminDB();
            
            if (defId == -1) {
            
    	        // Obtain PortalSettings from Current Context
		        PortalSettings portalSettings = (PortalSettings) Context.Items["PortalSettings"];

                // Add a new module definition to the database
                admin.AddModuleDefinition(portalSettings.PortalId, FriendlyName.Text, DesktopSrc.Text, MobileSrc.Text);
            }
            else {
            
                // update the module definition
                admin.UpdateModuleDefinition(defId, FriendlyName.Text, DesktopSrc.Text, MobileSrc.Text);
            }
            
            // Redirect back to the portal admin page
            Response.Redirect("~/DesktopDefault.aspx?tabindex=" + tabIndex + "&tabid=" + tabId);
        }
    }

    //****************************************************************
    //
    // The DeleteBtn_Click event handler on this Page is used to delete an
    // a link.  It  uses the ASPNetPortal.LinksDB()
    // data component to encapsulate all data functionality.
    //
    //****************************************************************

    void DeleteBtn_Click(Object sender, EventArgs e) {

        // delete definition
        ASPNetPortal.AdminDB admin = new ASPNetPortal.AdminDB();
        admin.DeleteModuleDefinition(defId);

        // Redirect back to the portal admin page
        Response.Redirect("~/DesktopDefault.aspx?tabindex=" + tabIndex + "&tabid=" + tabId);
    }

    //****************************************************************
    //
    // The CancelBtn_Click event handler on this Page is used to cancel
    // out of the page -- and return the user back to the portal home
    // page.
    //
    //****************************************************************

    void CancelBtn_Click(Object sender, EventArgs e) {

        // Redirect back to the portal home page
        Response.Redirect("~/DesktopDefault.aspx?tabindex=" + tabIndex + "&tabid=" + tabId);
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
                        <portal:Banner id="SiteHeader" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <br>
                        <table width="98%" cellspacing="0" cellpadding="4" border="0">
                            <tr valign="top">
                                <td width="150">
                                    &nbsp;
                                </td>
                                <td width="*">
                                    <table width="500" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="left" class="Head">
                                                Module Type Definition
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <hr noshade size="1pt">
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="750" cellspacing="0" cellpadding="0" border="0">
                                        <tr>
                                            <td width="100" class="SubHead">
                                                Friendly Name:
                                            </td>
                                            <td rowspan="5">
                                                &nbsp;
                                            </td>
                                            <td>
                                                <asp:TextBox id="FriendlyName" cssclass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td width="25" rowspan="5">
                                                &nbsp;
                                            </td>
                                            <td class="Normal" width="250">
                                                <asp:RequiredFieldValidator id="Req1" Display="Static" ErrorMessage="Enter a Module NAme" ControlToValidate="FriendlyName" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead" nowrap>
                                                Desktop Source:
                                            </td>
                                            <td>
                                                <asp:TextBox id="DesktopSrc" cssclass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td class="Normal">
                                                <asp:RequiredFieldValidator id="Req2" Display="Static" ErrorMessage="You Must Enter Source Path for the Desktop Module" ControlToValidate="DesktopSrc" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="SubHead">
                                                Mobile Source:
                                            </td>
                                            <td>
                                                <asp:TextBox id="MobileSrc" cssclass="NormalTextBox" width="390" Columns="30" maxlength="150" runat="server" />
                                            </td>
                                            <td>
                                                &nbsp;
                                            </td>
                                        </tr>
                                    </table>
                                    <p>
                                        <asp:LinkButton id="updateButton" Text="Update" runat="server" class="CommandButton" BorderStyle="none" OnClick="UpdateBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="cancelButton" Text="Cancel" CausesValidation="False" runat="server" class="CommandButton" BorderStyle="none" OnClick="CancelBtn_Click" />
                                        &nbsp;
                                        <asp:LinkButton id="deleteButton" Text="Delete this module type" CausesValidation="False" runat="server" class="CommandButton" BorderStyle="none" OnClick="DeleteBtn_Click" />
                                    </p>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
    </body>
</html>
