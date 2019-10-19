<%@ Control language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<script runat="server">

    //*******************************************************
    //
    // The Page_Load event handler on this User Control is used to
    // obtain a SqlDataReader of document information from the 
    // Documents table, and then databind the results to a DataGrid
    // server control.  It uses the ASPNetPortal.DocumentDB()
    // data component to encapsulate all data functionality.
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Obtain Document Data from Documents table
        // and bind to the datalist control
        ASPNetPortal.DocumentDB documents = new ASPNetPortal.DocumentDB();

        myDataGrid.DataSource = documents.GetDocuments(ModuleId);
        myDataGrid.DataBind();
    }

    //*******************************************************
    //
    // GetBrowsePath() is a helper method used to create the url   
    // to the document.  If the size of the content stored in the   
    // database is non-zero, it creates a path to browse that.   
    // Otherwise, the FileNameUrl value is used.
    //
    // This method is used in the databinding expression for
    // the browse Hyperlink within the DataGrid, and is called 
    // for each row when DataGrid.DataBind() is called.  It is 
    // defined as a helper method here (as opposed to inline 
    // within the template) to improve code organization and
    // avoid embedding logic within the content template.
    //
    //*******************************************************

    String GetBrowsePath(String url, object size, int documentId) {

        if (size != DBNull.Value && (int) size > 0) {
        
            // if there is content in the database, create an 
            // url to browse it
            
            return "~/DesktopModules/ViewDocument.aspx?DocumentID=" + documentId.ToString();
        }
        else {
            
            // otherwise, return the FileNameUrl
            return url;
        }
    }


</script>
<portal:title EditText="Add New Document" EditUrl="~/DesktopModules/EditDocs.aspx" runat="server" />
<asp:datagrid id="myDataGrid" Border="0" width="100%" AutoGenerateColumns="false" EnableViewState="false" runat="server">
    <Columns>
        <asp:TemplateColumn>
            <ItemTemplate>
                <asp:HyperLink id="editLink" ImageUrl="~/images/edit.gif" NavigateUrl='<%# "~/DesktopModules/EditDocs.aspx?ItemID=" + DataBinder.Eval(Container.DataItem,"ItemID")  + "&mid=" + ModuleId %>' Visible="<%# IsEditable %>" runat="server" />
            </ItemTemplate>
        </asp:TemplateColumn>
        <asp:TemplateColumn HeaderText="Title" HeaderStyle-CssClass="NormalBold">
            <ItemTemplate>
                <asp:HyperLink id="docLink" Text='<%# DataBinder.Eval(Container.DataItem,"FileFriendlyName") %>' NavigateUrl='<%# GetBrowsePath(DataBinder.Eval(Container.DataItem,"FileNameUrl").ToString(), DataBinder.Eval(Container.DataItem,"ContentSize"), (int) DataBinder.Eval(Container.DataItem,"ItemId")) %>' CssClass="Normal" Target="_new" runat="server" />
            </ItemTemplate>
        </asp:TemplateColumn>
        <asp:BoundColumn HeaderText="Owner" DataField="CreatedByUser" ItemStyle-CssClass="Normal" HeaderStyle-Cssclass="NormalBold" />
        <asp:BoundColumn HeaderText="Area" DataField="Category" ItemStyle-Wrap="false" ItemStyle-CssClass="Normal" HeaderStyle-Cssclass="NormalBold" />
        <asp:BoundColumn HeaderText="Last Updated" DataField="CreatedDate" DataFormatString="{0:d}" ItemStyle-CssClass="Normal" HeaderStyle-Cssclass="NormalBold" />
    </Columns>
</asp:datagrid>
