<%@ Control language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Import Namespace="ASPNetPortal" %>
<script runat="server">

    String linkImage = "";

    //*******************************************************
    //
    // The Page_Load event handler on this User Control is used to
    // obtain a DataReader of link information from the Links
    // table, and then databind the results to a templated DataList
    // server control.  It uses the ASPNetPortal.LinkDB()
    // data component to encapsulate all data functionality.
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Set the link image type
        if (IsEditable) {
            linkImage = "~/images/edit.gif";
        }
        else {
            linkImage = "~/images/navlink.gif";
        }

        // Obtain links information from the Links table
        // and bind to the list control
        ASPNetPortal.LinkDB links = new ASPNetPortal.LinkDB();

        myDataList.DataSource = links.GetLinks(ModuleId);
        myDataList.DataBind();
        
        // Ensure that only users in role may add links
        if (PortalSecurity.IsInRoles(ModuleConfiguration.AuthorizedEditRoles)) {

            EditButton.Text="Add Link";
            EditButton.NavigateUrl = "~/DesktopModules/EditLinks.aspx?mid=" + ModuleId.ToString();
        }
    }

</script>
<hr noshade size="1pt" width="98%">
<span class="SubSubHead">Quick Launch</span> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<asp:hyperlink id="EditButton" cssclass="CommandButton" EnableViewState="false" runat="server" />
<asp:DataList id="myDataList" CellPadding="4" Width="100%" EnableViewState="false" runat="server">
    <ItemTemplate>
        <span class="Normal">
            <asp:HyperLink id="editLink" ImageUrl="<%# linkImage %>" NavigateUrl='<%# "~/DesktopModules/EditLinks.aspx?ItemID=" + DataBinder.Eval(Container.DataItem,"ItemID") + "&mid=" + ModuleId %>' runat="server" />
            <a href='<%# DataBinder.Eval(Container.DataItem,"Url") %>'>
                <%# DataBinder.Eval(Container.DataItem,"Title") %>
            </a></span>
        <br>
    </ItemTemplate>
</asp:DataList>
<br>
