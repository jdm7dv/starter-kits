<%@ Import Namespace="ASPNetPortal" %>
<%@ Import Namespace="System.Security" %>
<%@ Import Namespace="System.Security.Principal" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<script language="C#" runat="server">

    //*********************************************************************
    //
    // Application_BeginRequest Event
    //
    // The Application_BeginRequest method is an ASP.NET event that executes 
    // on each web request into the portal application.  The below method
    // obtains the current tabIndex and TabId from the querystring of the 
    // request -- and then obtains the configuration necessary to process
    // and render the request.
    //
    // This portal configuration is stored within the application's "Context"
    // object -- which is available to all pages, controls and components
    // during the processing of a single request.
    // 
    //*********************************************************************

    void Application_BeginRequest(Object sender, EventArgs e) {
                
        int tabIndex = 0;
        int tabId = 0;
        
        // Get TabIndex from querystring
        
        if (Request.Params["tabindex"] != null) {               
            tabIndex = Int32.Parse(Request.Params["tabindex"]);
        }
                        
        // Get TabID from querystring
        
        if (Request.Params["tabid"] != null) {              
            tabId = Int32.Parse(Request.Params["tabid"]);
        }
        
        Context.Items.Add("PortalSettings", new PortalSettings(tabIndex, tabId));
    }
                          
    //*********************************************************************
    //
    // Application_AuthenticateRequest Event
    //
    // If the client is authenticated with the application, then determine
    // which security roles he/she belongs to and replace the "User" intrinsic
    // with a custom IPrincipal security object that permits "User.IsInRole"
    // role checks within the application
    //
    // Roles are cached in the browser in an in-memory encrypted cookie.  If the
    // cookie doesn't exist yet for this session, create it.
    //
    //*********************************************************************

    void Application_AuthenticateRequest(Object sender, EventArgs e) {

        if (Request.IsAuthenticated == true) {

            String[] roles;

            // Create the roles cookie if it doesn't exist yet for this session.
            if ((Request.Cookies["portalroles"] == null) || (Request.Cookies["portalroles"].Value == "")) {

                // Get roles from UserRoles table, and add to cookie
                UsersDB user = new UsersDB();
                roles = user.GetRoles(User.Identity.Name);
                
                // Create a string to persist the roles
                String roleStr = "";
                foreach (String role in roles) {
                    roleStr += role;
                    roleStr += ";";
                }

                // Create a cookie authentication ticket.
                FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                        1,                              // version
                        Context.User.Identity.Name,     // user name
                        DateTime.Now,                   // issue time
                        DateTime.Now.AddHours(1),       // expires every hour
                        false,                          // don't persist cookie
                        roleStr                         // roles
                    );

                // Encrypt the ticket
                String cookieStr = FormsAuthentication.Encrypt(ticket);

                // Send the cookie to the client
                Response.Cookies["portalroles"].Value = cookieStr;
                Response.Cookies["portalroles"].Path = "/";
                Response.Cookies["portalroles"].Expires = DateTime.Now.AddMinutes(1);
            }
            else {

                // Get roles from roles cookie
                FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(Context.Request.Cookies["portalroles"].Value);

                //convert the string representation of the role data into a string array
                ArrayList userRoles = new ArrayList();

                foreach (String role in ticket.UserData.Split( new char[] {';'} )) {
                    userRoles.Add(role);
                }

                roles = (String[]) userRoles.ToArray(typeof(String));
            }

            // Add our own custom principal to the request containing the roles in the auth ticket
            Context.User = new GenericPrincipal(Context.User.Identity, roles);
        }
    }

</script>