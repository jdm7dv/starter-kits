<%@ Control Language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<script runat="server">

    //*******************************************************
    //
    // The Page_Load event handler on this User Control is used to
    // obtain a DataSet of announcement information from the Announcements
    // table, and then databind the results to a templated DataList
    // server control.  It uses the ASPNetPortal.AnnouncementsDB()
    // data component to encapsulate all data functionality.
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Obtain announcement information from Announcements table
        // and bind to the datalist control
        ASPNetPortal.AnnouncementsDB announcements = new ASPNetPortal.AnnouncementsDB();

        // DataBind Announcements to DataList Control
        myDataList.DataSource = announcements.GetAnnouncements(ModuleId);
        myDataList.DataBind();
    }

</script>
<portal:title EditText="Add New Announcement" EditUrl="~/DesktopModules/EditAnnouncements.aspx" runat="server" />
<asp:DataList id="myDataList" CellPadding="4" Width="98%" EnableViewState="false" runat="server">
    <ItemTemplate>
        <asp:HyperLink id="editLink" ImageUrl="~/images/edit.gif" NavigateUrl='<%# "~/DesktopModules/EditAnnouncements.aspx?ItemID=" + DataBinder.Eval(Container.DataItem,"ItemID") + "&mid=" + ModuleId %>' Visible="<%# IsEditable %>" runat="server" />
        <span class="ItemTitle">
            <%# DataBinder.Eval(Container.DataItem,"Title") %>
        </span>
        <br>
        <span class="Normal">
            <%# DataBinder.Eval(Container.DataItem,"Description") %>
            &nbsp;
            <asp:HyperLink id="moreLink" NavigateUrl='<%# DataBinder.Eval(Container.DataItem,"MoreLink") %>' Visible='<%# DataBinder.Eval(Container.DataItem,"MoreLink") != String.Empty %>' runat="server">
                read more...</asp:HyperLink>
        </span>
        <br>
    </ItemTemplate>
</asp:DataList>
