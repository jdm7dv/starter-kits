<%@ Control language="C#" Inherits="ASPNetPortal.PortalModuleControl" %>
<%@ Register TagPrefix="Portal" TagName="Title" Src="~/DesktopModuleTitle.ascx"%>
<%@ Import Namespace="System.Data.SqlClient" %>
<script runat="server">

    //*******************************************************
    //
    // The Page_Load event handler on this User Control is
    // used to render a block of HTML or text to the page.  
    // The text/HTML to render is stored in the HtmlText 
    // database table.  This method uses the ASPNetPortal.HtmlTextDB()
    // data component to encapsulate all data functionality.
    //
    //*******************************************************

    void Page_Load(Object sender, EventArgs e) {

        // Obtain the selected item from the HtmlText table
        ASPNetPortal.HtmlTextDB text = new ASPNetPortal.HtmlTextDB();
        SqlDataReader dr = text.GetHtmlText(ModuleId);
        
        if (dr.Read()) {

            // Dynamically add the file content into the page
            String content = Server.HtmlDecode((String) dr["DesktopHtml"]);
            HtmlHolder.Controls.Add(new LiteralControl(content));
        }
        
        // Close the datareader
        dr.Close();       
    }

</script>
<portal:title EditText="Edit" EditUrl="~/DesktopModules/EditHtml.aspx" runat="server" />
<table id="t1" cellspacing="0" cellpadding="0" runat="server">
    <tr valign="top">
        <td id="HtmlHolder" runat="server">
        </td>
    </tr>
</table>
