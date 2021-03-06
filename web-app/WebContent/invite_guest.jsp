<%@page import="java.util.*"%>
<%@page import="helper.*"%>
<jsp:useBean id="usersession" class="helper.UserSession" scope="session" />
<jsp:useBean id="dbaccess" class="db.DBAccess" scope="session" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SenecaBBB | Create Guest Account</title>
    <link rel="shortcut icon" href="http://www.senecacollege.ca/favicon.ico">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/fonts.css">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/style.css">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/jquery.ui.core.css">
    <link rel="stylesheet" type="text/css" media="all" href="${pageContext.servletContext.contextPath}/${initParam.CSSDirectory}/themes/base/jquery.ui.theme.css">
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/jquery-1.9.1.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/modernizr.custom.79639.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.core.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.widget.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.position.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/ui/jquery.ui.stepper.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/jquery.validate.min.js"></script>
    <script type="text/javascript" src="${pageContext.servletContext.contextPath}/${initParam.JavaScriptDirectory}/additional-methods.min.js"></script>
</head>
<body>
    <%
    //Start page validation
    String userId = usersession.getUserId();
    GetExceptionLog elog = new GetExceptionLog();
    HashMap<String, Integer> roleMask = usersession.getRoleMask();
    if (userId.equals("")) {
        session.setAttribute("redirecturl", request.getRequestURI() + (request.getQueryString()!=null?"?" + request.getQueryString():""));
        response.sendRedirect("index.jsp?message=Please log in");
        return;
    }
    if(!(usersession.isSuper()||usersession.getUserLevel().equals("employee")||roleMask.get("guestAccountCreation") == 0)) {
        elog.writeLog("[invite_guest:] " + " username: "+ userId + " tried to access this page, permission denied" + " /n");	       
        response.sendRedirect("calendar.jsp?message=You do not have permission to access that page");
        return;
    }
    if (dbaccess.getFlagStatus() == false) {
        elog.writeLog("[invite_guest:] " + "database connection error /n");
        response.sendRedirect("index.jsp?message=Database connection error");
        return;
    }//End page validation
    
    String message = request.getParameter("message");
    String successMessage = request.getParameter("successMessage");
    if (message == null || message == "null") {
        message = "";
    }
    if (successMessage == null) {
        successMessage = "";
    }

    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String email = request.getParameter("email");
    %>
    <div id="page">
        <jsp:include page="header.jsp"/>
        <jsp:include page="menu.jsp"/>
        <section>
            <header>
                <p>
                    <a href="calendar.jsp" tabindex="13">home</a>  � 
                    <a href="invite_guest.jsp" tabindex="14">create guest account</a>
                </p>
                <h1>Create Guest Account</h1>
                <!-- WARNING MESSAGES -->
                <div class="warningMessage"><%= message %></div>
                <div class="successMessage"><%= successMessage %></div> 
            </header>
            <form name="guestaccuntinfo" id="guestaccuntinfo"  method="get" action="generate_guest.jsp">
                <article>
                    <header>
                        <h2>Guest Information</h2>
                    </header>
                    <fieldset>
                        <div class="component">
                            <label for="firstName" class="label"> first name:</label>
                            <input type="text" name="firstName" id="firstName" class="input" tabindex="15" title="First Name" <% if(firstName != null) out.print("value="+firstName); %>>
                        </div>
                        <div class="component">
                            <label for="lastName" class="label"> last name:</label>
                            <input type="text" name="lastName" id="lastName" class="input" tabindex="16" title="Last Name" <% if(lastName != null) out.print("value="+lastName); %>>
                        </div>
                        <div class="component">
                            <label for="email" class="label">Guest email:</label>
                            <input type="email" name="email" id="email" class="input" tabindex="17" title="Email" <% if(email != null) out.print("value="+email); %>>
                        </div>
                    </fieldset>
                </article>
                <article>
                    <fieldset>
                        <div class="buttons">
                            <button type="submit" name="submit" id="save" class="button" title="Click here to create account">Create</button>
                            <button type="button" name="button" id="cancel"  class="button" title="Click here to cancel" onclick="window.location.href='<% if(usersession.isSuper()) out.print("manage_users.jsp"); else out.print("calendar.jsp");%>'">Cancel</button>
                        </div>
                    </fieldset>
                </article>
            </form>
        </section>
        <script>    
           // form validation, edit the regular expression pattern and error messages to meet your needs
           $(document).ready(function(){
                $('#guestaccuntinfo').validate({
                    validateOnBlur : true,
                    rules: {
                        firstName: {
                            required: true,
                            minlength: 2,
                            maxlength: 45,
                            pattern: /^\s*([a-zA-Z]+[\s]*[\'\,\.\-]?[\s]*){1,5}\s*$/
                        },
                        lastName:{
                            required: true,
                            minlength: 2,
                            maxlength: 45,
                            pattern: /^\s*([a-zA-Z]+[\s]*[\'\,\.\-]?[\s]*){1,5}\s*$/
                        },
                        email:{
                            required: true,
                            email: true
                        }
                    },
                    messages: {
                        firstName: {
                            required: "Please enter guest first name",
                            pattern: "invalid name",
                            minlength:"minimum 2 characters",
                            maxlength:"maximum 45 characters"
                        },
                        lastName:{
                            required: "Please enter guest last name",
                            pattern: "invalid name",
                            minlength:"minimum 2 characters",
                            maxlength:"maximum 45 characters"
                        },
                        email:{
                            required: "Please enter guest email address",
                            email: "Please enter a valid email address"
                        }
                    }
                });
            });
        </script>
        <jsp:include page="footer.jsp"/>
    </div>
</body>
</html>
