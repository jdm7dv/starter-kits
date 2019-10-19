<%@ Control language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
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
        // and bind to the datalist control
        ASPNetPortal.LinkDB links = new ASPNetPortal.LinkDB();

        myDataList.DataSource = links.GetLinks(ModuleId);
        myDataList.DataBind();
    }

</script>
<portal:title EditUrl="~/DesktopModules/EditLinks.aspx" EditText="Add Link" runat="server" />
<asp:DataList id="myDataList" CellPadding="4" Width="100%" runat="server">
    <ItemTemplate>
        <span class="Normal">
            <asp:HyperLink id="editLink" ImageUrl="<%# linkImage %>" NavigateUrl='<%# "~/DesktopModules/EditLinks.aspx?ItemID=" + DataBinder.Eval(Container.DataItem,"ItemID") + "&mid=" + ModuleId %>' runat="server" />
            <asp:HyperLink Text='<%# DataBinder.Eval(Container.DataItem,"Title") %>' NavigateUrl='<%# DataBinder.Eval(Container.DataItem,"Url") %>' ToolTip='<%# DataBinder.Eval(Container.DataItem,"Description") %>' Target="_new" runat="server" />
        </span>
        <br>
    </ItemTemplate>
</asp:DataList>
